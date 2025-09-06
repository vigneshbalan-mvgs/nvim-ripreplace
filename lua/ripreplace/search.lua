local state = require("ripreplace.state")
local ui = require("ripreplace.ui")
local config = require("ripreplace").config -- Access the global config
local M = {}

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
  state.last.search = search
  state.last.replace = nil

  local cmd = { "rg", "--vimgrep", "--no-heading", search }
  state.last.results = vim.fn.systemlist(cmd)
  if #state.last.results == 0 then
    vim.notify("No matches found", vim.log.levels.INFO)
    return
  end

  if config.use_telescope then
    local telescope_integration = require("ripreplace.integrations.telescope")
    telescope_integration.setup_picker(state.last.results)
  else
    ui.show_preview(false)
  end
end

return M