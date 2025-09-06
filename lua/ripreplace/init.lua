local M = {}

-- Example function: just writes a message
function M.hello()
  print("Ripreplace says hello 👋")
end

-- Example function: write to current buffer
function M.write_line(text)
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1 -- current line (0-based)
  vim.api.nvim_buf_set_lines(0, row, row, false, { text })
end

-- Your ripgrep replace logic could also go here:
function M.replace(search, replace)
  local cmd = { "rg", "--vimgrep", search }
  local result = vim.fn.systemlist(cmd)

  for _, line in ipairs(result) do
    local file, lnum = line:match("([^:]+):(%d+):")
    if file and lnum then
      local bufnr = vim.fn.bufadd(file)
      vim.fn.bufload(bufnr)

      local l = tonumber(lnum) - 1
      local current = vim.api.nvim_buf_get_lines(bufnr, l, l + 1, false)[1]
      local updated = current:gsub(search, replace)
      vim.api.nvim_buf_set_lines(bufnr, l, l + 1, false, { updated })

      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("update")
      end)
    end
  end
end

return M
