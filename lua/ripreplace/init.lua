local M = {}

M.config = {
  use_telescope = false, -- Default to false
}

local search = require("ripreplace.search")
search.set_config(M.config)

-- Setup keymaps and configuration
function M.setup(opts)
  opts = opts or {}
  for k, v in pairs(opts) do
    M.config[k] = v
  end

  vim.keymap.set({ "n", "v" }, "<leader>rr", search.project_search, { desc = "Project-wide search & replace preview" })
end

return M