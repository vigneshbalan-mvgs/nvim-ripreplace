local state = require("ripreplace.state")
local M = {}

-- Apply replacement: interactive (one-by-one) or all at once
function M.apply_replace(one_by_one)
  if not state.last.replace or state.last.replace == "" then return end
  if not state.last.search or #state.last.results == 0 then return end

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
          -- Replace and continue
          local f = io.open(file, "r")
          local content = f:read("*all")
          f:close()
          local replaced_content = content:gsub(state.last.search, state.last.replace, 1) -- Replace only the first occurrence
          f = io.open(file, "w")
          f:write(replaced_content)
          f:close()
          vim.notify("Replaced one occurrence in " .. file, vim.log.levels.INFO)
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
  for _, res in ipairs(state.last.results) do
    local file, _, _, _ = res:match("([^:]+):(%d+):(%d+):(.*)")
    if file then
      local f = io.open(file, "r")
      if not f then goto continue end
      local content = f:read("*all")
      f:close()
      local replaced_content = content:gsub(state.last.search, state.last.replace)
      f = io.open(file, "w")
      if f then
        f:write(replaced_content)
        f:close()
      end
    end
    ::continue::
  end

  vim.notify("replacement is ok!")
end

return M