local M = {}

function M.hello()
  print("Ripreplace says hello 👋")
end

-- Telescope-powered ripgrep search
function M.search(prompt)
  local has_telescope, telescope = pcall(require, "telescope.builtin")
  if not has_telescope then
    vim.notify("Telescope not found", vim.log.levels.ERROR)
    return
  end

  telescope.grep_string({
    search = prompt or vim.fn.input("Ripgrep > "),
  })
end

-- Example: replace logic (still rough)
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

function M.setup()
  -- Define a user command :RgSearch
  vim.api.nvim_create_user_command("RgSearch", function()
    require("ripreplace").search()
  end, {})
end

return M
