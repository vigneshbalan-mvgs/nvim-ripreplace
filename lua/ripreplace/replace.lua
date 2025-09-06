local state = require("ripreplace.state")
local M = {}

-- Apply replacement: interactive (one-by-one) or all at once
function M.apply_replace(one_by_one)
  if not state.last.search or #state.last.results == 0 then return end
  if not state.last.replace or state.last.replace == "" then
    state.last.replace = vim.fn.input("Replace '" .. state.last.search .. "' with > ")
    if not state.last.replace or state.last.replace == "" then
      vim.notify("Replacement text is empty. Aborting.", vim.log.levels.WARN)
      return
    end
  end

  if one_by_one then
    local result_count = #state.last.results
    while state.last.current_result_index <= result_count do
      local res = state.last.results[state.last.current_result_index]
      local file, lnum, col, _ = res:match("([^:]+):(%d+):(%d+):(.*)")
      if file then
        vim.cmd("edit " .. file)
        vim.api.nvim_win_set_cursor(0, { tonumber(lnum), tonumber(col) - 1 })

        local choice = vim.fn.confirm("Replace '" .. state.last.search .. "' in this file?", "&Yes\n&No\n&All", 1)

        if choice == 1 then
          -- Replace and continue (buffer-aware)
          local bufnr = vim.api.nvim_get_current_buf()
          local line_index = tonumber(lnum) - 1 -- nvim API is 0-based
          local col_num = tonumber(col)
          local lines = vim.api.nvim_buf_get_lines(bufnr, line_index, line_index + 1, false)
          if #lines > 0 then
            local line_content = lines[1]
            local search_len = #state.last.search
            local new_line = line_content:sub(1, col_num - 1)
              .. state.last.replace
              .. line_content:sub(col_num + search_len)
            vim.api.nvim_buf_set_lines(bufnr, line_index, line_index + 1, false, { new_line })
            vim.cmd("write")
            vim.notify("Replaced one occurrence in " .. file, vim.log.levels.INFO)
          else
            vim.notify("Unable to read target line from buffer: " .. file, vim.log.levels.ERROR)
          end
        elseif choice == 2 then
          -- Skip and continue
          vim.notify("Skipped.", vim.log.levels.INFO)
        elseif choice == 3 then
          -- Replace all and exit
          M.apply_replace(false)
          return
        end
      end
      state.last.current_result_index = state.last.current_result_index + 1
    end
    vim.notify("One-by-one replacements finished.", vim.log.levels.INFO)
    return
  end

  -- Replace all logic
  local file_contents = {} -- Store file contents as tables of lines
  local file_matches = {} -- Store matches grouped by file and line

  for _, res in ipairs(state.last.results) do
    local file, lnum, col, _ = res:match("([^:]+):(%d+):(%d+):(.*)")
    if file then
      lnum = tonumber(lnum)
      col = tonumber(col)

      -- Initialize file_contents if not already done
      if not file_contents[file] then
        local f = io.open(file, "r")
        if f then
          local content = f:read("*all")
          f:close()
          file_contents[file] = vim.split(content, "\n", { plain = true })
        else
          vim.notify("Error opening file for reading: " .. file, vim.log.levels.ERROR)
        end
      end

      -- Store matches for later processing (grouped by file and line)
      if file_contents[file] then
        if not file_matches[file] then file_matches[file] = {} end
        if not file_matches[file][lnum] then file_matches[file][lnum] = {} end
        table.insert(file_matches[file][lnum], { col = col })
      end
    end
  end

  -- Apply replacements from right to left on each line
  for file, lines_data in pairs(file_matches) do
    for lnum, matches in pairs(lines_data) do
      -- Sort matches by column in descending order
      table.sort(matches, function(a, b) return a.col > b.col end)

      local current_line = file_contents[file][lnum]
      if current_line then
        for _, match_info in ipairs(matches) do
          local col = match_info.col
          local start_index = col
          local end_index = start_index + #state.last.search - 1
          current_line = current_line:sub(1, start_index - 1) .. state.last.replace .. current_line:sub(end_index + 1)
        end
        file_contents[file][lnum] = current_line
      end
    end
  end

  -- Write back modified files (refresh open buffers and write)
  for file, lines in pairs(file_contents) do
    local bufnr = vim.fn.bufnr(file)
    if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
      -- Update buffer directly and write to disk
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("write")
      end)
    else
      -- Fallback: write via file I/O
      local f = io.open(file, "w")
      if f then
        f:write(table.concat(lines, "\n"))
        f:close()
      else
        vim.notify("Error opening file for writing: " .. file, vim.log.levels.ERROR)
      end
    end
  end

  vim.notify("replacement is ok!")
end

return M