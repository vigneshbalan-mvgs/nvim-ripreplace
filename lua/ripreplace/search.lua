local M = {}
local state = require("ripreplace.state")
local ui = require("ripreplace.ui")
local config -- Will be set by init.lua

function M.set_config(cfg)
  config = cfg
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
  if search:find("\n") then
    vim.notify("Multi-line search is not supported. Please select a single line or enter a single-line query.", vim.log.levels.WARN)
    return
  end
  state.last.search = search
  state.last.replace = nil

  -- Use literal matching to align with our replacement logic (plain text)
  local cmd = { "rg", "--vimgrep", "--no-heading", "-F", search }
  state.last.results = vim.fn.systemlist(cmd)
  if #state.last.results == 0 then
    vim.notify("No matches found", vim.log.levels.INFO)
    return
  end

  if config.use_telescope then
    local ok, telescope_integration = pcall(require, "ripreplace.integrations.telescope")
    if ok then
      telescope_integration.setup_picker(state.last.results)
    else
      vim.notify("Telescope integration not available. Falling back to built-in preview.", vim.log.levels.WARN)
      ui.show_preview(false)
    end
  else
    ui.show_preview(false)
  end
end

return M