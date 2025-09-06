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

  vim.keymap.set({ "n", "v" }, "<leader>rp", search.project_search, { desc = "Project-wide search & replace preview" })
  vim.keymap.set({ "n", "v" }, "<leader>rr", require("ripreplace.replace").single_file_replace, { desc = "Single file search & replace" })
  vim.cmd("command! RipreplaceSingle lua require('ripreplace.replace').single_file_replace()")
end

return M