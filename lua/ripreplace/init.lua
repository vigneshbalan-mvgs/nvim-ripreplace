local M = {}
M.last = { search = nil, replace = nil, results = {}, current_result_index = 0 }
local active_win = nil
local active_buf = nil

-- Helper: open or update a floating window
local function open_float(lines)
  if active_win and vim.api.nvim_win_is_valid(active_win) then
    vim.api.nvim_buf_set_lines(active_buf, 0, -1, false, lines)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.7)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })

  active_buf = buf
  active_win = win

  -- Keymaps inside popup
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(active_win, true)
    active_win = nil
    active_buf = nil
  end, { buffer = buf })

  vim.keymap.set("n", "r", function()
    M.last.replace = vim.fn.input("Replace '" .. M.last.search .. "' with > ")
    if M.last.replace ~= "" then M.show_preview(true) end
  end, { buffer = buf })

  vim.keymap.set("n", "a", function()
    M.apply_replace(false)
    vim.api.nvim_win_close(active_win, true)
    active_win = nil
    active_buf = nil
  end, { buffer = buf })

  vim.keymap.set("n", "o", function()
    M.last.current_result_index = 1
    M.apply_replace(true)
  end, { buffer = buf })
end

-- Build preview lines
function M.build_lines(with_replace)
  local header = with_replace and
      "Preview Replacements (r=edit, a=replace all, o=one-by-one, q=quit)" or
      "Search Results (r=replace, a=replace all, o=one-by-one, q=quit)"
  local lines = { header, "" }
  for _, res in ipairs(M.last.results) do
    local file, lnum, _, text = res:match("([^:]+):(%d+):(%d+):(.*)")
    if file and text then
      if with_replace and M.last.replace then
        local replaced = text:gsub(M.last.search, M.last.replace)
        table.insert(lines, string.format("%s:%s | %s → %s", file, lnum, text, replaced))
      else
        table.insert(lines, string.format("%s:%s | %s", file, lnum, text))
      end
    end
  end
  return lines
end

-- Show floating preview
function M.show_preview(with_replace)
  local lines = M.build_lines(with_replace)
  open_float(lines)
end

-- Project-wide search
function M.project_search()
  local mode = vim.fn.mode()
  local search = ""

  if mode:match("[vV]") then
    -- Visual selection
    local _, ls, cs = unpack(vim.fn.getpos("'<"))
    local _, le, ce = unpack(vim.fn.getpos("'>"))
    local lines = vim.fn.getline(ls, le)
    if #lines == 0 then return end
    lines[#lines] = string.sub(lines[#lines], 1, ce)
    lines[1] = string.sub(lines[1], cs)
    search = table.concat(lines, "\n")
  else
    -- Normal mode: ask input
    search = vim.fn.input("Search for > ")
  end

  if search == "" then return end
  M.last.search = search
  M.last.replace = nil

  local cmd = { "rg", "--vimgrep", "--no-heading", search }
  M.last.results = vim.fn.systemlist(cmd)
  if #M.last.results == 0 then
    vim.notify("No matches found", vim.log.levels.INFO)
    return
  end

  M.show_preview(false)
end

-- Apply replacement: interactive (one-by-one) or all at once
function M.apply_replace(one_by_one)
  if not M.last.replace or M.last.replace == "" then return end
  if not M.last.search or #M.last.results == 0 then return end

  if one_by_one then
    local result_count = #M.last.results
    while M.last.current_result_index <= result_count do
      local res = M.last.results[M.last.current_result_index]
      local file, lnum, col, _ = res:match("([^:]+):(%d+):(%d+):(.*)")
      if file then
        vim.cmd("edit " .. file)
        vim.api.nvim_win_set_cursor(0, { tonumber(lnum), tonumber(col) - 1 })

        local choice = vim.fn.confirm("Replace '" .. M.last.search .. "' in this file?", "&Yes\n&No\n&All", 1)

        if choice == 1 then
          -- Replace and continue
          local f = io.open(file, "r")
          local content = f:read("*all")
          f:close()
          local replaced_content = content:gsub(M.last.search, M.last.replace, 1) -- Replace only the first occurrence
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
      M.last.current_result_index = M.last.current_result_index + 1
    end
    vim.notify("One-by-one replacements finished.", vim.log.levels.INFO)
    return
  end

  -- Replace all logic
  for _, res in ipairs(M.last.results) do
    local file, _, _, _ = res:match("([^:]+):(%d+):(%d+):(.*)")
    if file then
      local f = io.open(file, "r")
      if not f then goto continue end
      local content = f:read("*all")
      f:close()
      local replaced_content = content:gsub(M.last.search, M.last.replace)
      f = io.open(file, "w")
      if f then
        f:write(replaced_content)
        f:close()
      end
    end
    ::continue::
  end

  vim.notify("Replacements done!")
end

-- Setup keymaps
function M.setup()
  vim.keymap.set({ "n", "v" }, "<leader>rr", M.project_search, { desc = "Project-wide search & replace preview" })
end

return M
