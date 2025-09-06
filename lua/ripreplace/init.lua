local M = {}
M.last = { search = nil, replace = nil }

-- helper: open floating window
local function open_float(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.7)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })

  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(0, true) end, { buffer = buf })
  return buf
end

-- preview replacements in popup
function M.preview_replace()
  if not M.last.search then
    vim.notify("No search recorded", vim.log.levels.WARN)
    return
  end
  if not M.last.replace then
    M.last.replace = vim.fn.input("Replace '" .. M.last.search .. "' with > ")
    if M.last.replace == "" then return end
  end

  local cmd = { "rg", "--vimgrep", "--no-heading", M.last.search }
  local results = vim.fn.systemlist(cmd)
  if #results == 0 then
    vim.notify("No matches found", vim.log.levels.INFO)
    return
  end

  local lines = { "Preview replacements (press q to close):", "" }
  for _, res in ipairs(results) do
    local file, lnum, col, text = res:match("([^:]+):(%d+):(%d+):(.*)")
    if file and text then
      local replaced = text:gsub(M.last.search, M.last.replace)
      table.insert(lines, string.format("%s:%s | %s → %s", file, lnum, text, replaced))
    end
  end

  open_float(lines)
end

-- setup (only keymaps for simplicity)
function M.setup()
  vim.keymap.set("n", "<leader>rr", function()
    local search = vim.fn.expand("<cword>")
    if search == "" then search = vim.fn.input("Search for > ") end
    M.last.search = search
    M.last.replace = nil
    M.preview_replace()
  end, { desc = "Project-wide search & preview replacements" })
end

return M
