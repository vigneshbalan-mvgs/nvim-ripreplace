local state = require("ripreplace.state")
local M = {}

-- Helper: open or update a floating window
local function open_float(lines)
  if state.active_win and vim.api.nvim_win_is_valid(state.active_win) then
    vim.api.nvim_buf_set_lines(state.active_buf, 0, -1, false, lines)
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

  state.active_buf = buf
  state.active_win = win

  -- Keymaps inside popup
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(state.active_win, true)
    state.active_win = nil
    state.active_buf = nil
  end, { buffer = buf })

  vim.keymap.set("n", "r", function()
    state.last.replace = vim.fn.input("Replace '" .. state.last.search .. "' with > ")
    if state.last.replace ~= "" then M.show_preview(true) end
  end, { buffer = buf })

  vim.keymap.set("n", "a", function()
    require("ripreplace.replace").apply_replace(false)
    vim.api.nvim_win_close(state.active_win, true)
    state.active_win = nil
    state.active_buf = nil
  end, { buffer = buf })

  vim.keymap.set("n", "o", function()
    state.last.current_result_index = 1
    require("ripreplace.replace").apply_replace(true)
  end, { buffer = buf })
end

-- Build preview lines
function M.build_lines(with_replace)
  local header = with_replace and
      "Preview Replacements (r=edit, a=replace all, o=one-by-one, q=quit)" or
      "Search Results (r=replace, a=replace all, o=one-by-one, q=quit)"
  local lines = { header, "" }
  for _, res in ipairs(state.last.results) do
    local file, lnum, _, text = res:match("([^:]+):(%d+):(%d+):(.*)")
    if file and text then
      if with_replace and state.last.replace then
        local replaced = text:gsub(state.last.search, state.last.replace)
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

return M