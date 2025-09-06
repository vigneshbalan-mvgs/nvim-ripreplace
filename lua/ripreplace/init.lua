local M = {}

function M.hello()
  print("Ripreplace says hello 👋")
end

function M.search(prompt)
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("Telescope not found", vim.log.levels.ERROR)
    return
  end
  telescope.grep_string({ search = prompt or vim.fn.input("Ripgrep > ") })
end

-- setup function (this is what Lazy calls)
function M.setup()
  vim.api.nvim_create_user_command("RgSearch", function()
    require("ripreplace").search()
  end, {})

  vim.keymap.set("n", "<leader>rg", function()
    require("ripreplace").search()
  end, { desc = "Ripgrep search via Telescope" })
end

return M
