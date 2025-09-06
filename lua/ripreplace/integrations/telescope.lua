local M = {}
local state = require("ripreplace.state")

function M.setup_picker(results)
  local telescope_builtin = require('telescope.builtin')
  local finders = require('telescope.finders')
  local pickers = require('telescope.pickers')
  local conf = require('telescope.config').values
  local entry_display = require('telescope.make_entry').gen_from_file_with_preview

  local initial_picker_opts = {
    finder = finders.new_table({
      results = results,
      entry_maker = function(entry)
        -- entry is a string like "file:lnum:col:text"
        local file, lnum, col, text = entry:match("([^:]+):(%d+):(%d+):(.*)")
        return {
          value = entry,
          display = string.format("%s:%s | %s", file, lnum, text),
          file = file,
          lnum = tonumber(lnum),
          col = tonumber(col),
          text = text,
          -- For previewer
          path = file,
          lnum_start = tonumber(lnum),
          col_start = tonumber(col),
          text_start = text,
        }
      end,
    }),
    sorter = conf.file_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      -- Add custom mappings here if needed
      return true
    end,
  }

  pickers.new(initial_picker_opts):find()
end

return M