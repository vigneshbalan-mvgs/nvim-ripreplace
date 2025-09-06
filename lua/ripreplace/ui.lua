local M = {}

local active_win = nil
local active_buf = nil
local main_module = nil -- To hold the reference to the main module (init.lua)

function M.open_ui(lines, is_visual_search, main_mod)
  main_module = main_mod -- Store the reference to the main module
  if main_module.config.ui == "float" then
    if not active_win or not vim.api.nvim_win_is_valid(active_win) then
      local buf = vim.api.nvim_create_buf(false, true)
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
        border = main_module.config.border,
      })

      active_buf = buf
      active_win = win

      -- Keymaps inside popup
      vim.keymap.set("n", main_module.config.keymaps.quit, function()
        M.close_ui()
      end, { buffer = buf })

      if is_visual_search then
        vim.keymap.set("n", main_module.config.keymaps.replace, function()
          main_module.last.replace = vim.fn.input("Replace '" .. main_module.last.search .. "' with > ")
          if main_module.last.replace ~= "" then
            M.close_ui()
            main_module.show_preview(true, false)
          end
        end, { buffer = buf })
      else
        vim.keymap.set("n", main_module.config.keymaps.edit, function()
          M.close_ui()
          main_module.open_input_modal(main_module.last.search, main_module.last.replace)
        end, { buffer = buf })
      end

      vim.keymap.set("n", main_module.config.keymaps.apply_all, function()
        main_module.apply_replace(false)
        M.close_ui()
      end, { buffer = buf })

      vim.keymap.set("n", main_module.config.keymaps.one_by_one, function()
        main_module.last.current_result_index = 1
        main_module.apply_replace(true)
      end, { buffer = buf })

      vim.keymap.set("n", main_module.config.keymaps.inline_edit, function()
        vim.api.nvim_buf_set_option(active_buf, "modifiable", true)
        vim.api.nvim_command("startinsert")
      end, { buffer = buf })

      vim.keymap.set("n", main_module.config.keymaps.save_inline_edit, function()
        vim.api.nvim_buf_set_option(active_buf, "modifiable", false)
        local lines = vim.api.nvim_buf_get_lines(active_buf, 0, -1, false)
        main_module.apply_inline_edit(lines)
      end, { buffer = buf })

      vim.keymap.set("n", main_module.config.keymaps.populate_quickfix, function()
        main_module.populate_quickfix()
      end, { buffer = buf })
    else -- split
      vim.cmd("botright split")
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(0, buf)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      active_buf = buf

      -- Keymaps inside split
      vim.keymap.set("n", main_module.config.keymaps.quit, function()
        M.close_ui()
      end, { buffer = buf })

      if is_visual_search then
        vim.keymap.set("n", main_module.config.keymaps.replace, function()
          main_module.last.replace = vim.fn.input("Replace '" .. main_module.last.search .. "' with > ")
          if main_module.last.replace ~= "" then
            M.close_ui()
            main_module.show_preview(true, false)
          end
        end, { buffer = buf })
      else
        vim.keymap.set("n", main_module.config.keymaps.edit, function()
          M.close_ui()
          main_module.open_input_modal(main_module.last.search, main_module.last.replace)
        end, { buffer = buf })
      end

      vim.keymap.set("n", main_module.config.keymaps.apply_all, function()
        main_module.apply_replace(false)
        M.close_ui()
      end, { buffer = buf })

      vim.keymap.set("n", main_module.config.keymaps.one_by_one, function()
        main_module.last.current_result_index = 1
        main_module.apply_replace(true)
      end, { buffer = buf })

      vim.keymap.set("n", main_module.config.keymaps.inline_edit, function()
        vim.api.nvim_buf_set_option(active_buf, "modifiable", true)
        vim.api.nvim_command("startinsert")
      end, { buffer = buf })

      vim.keymap.set("n", main_module.config.keymaps.save_inline_edit, function()
        vim.api.nvim_buf_set_option(active_buf, "modifiable", false)
        local lines = vim.api.nvim_buf_get_lines(active_buf, 0, -1, false)
        main_module.apply_inline_edit(lines)
      end, { buffer = buf })

      vim.keymap.set("n", main_module.config.keymaps.populate_quickfix, function()
        main_module.populate_quickfix()
      end, { buffer = buf })
    end

    vim.api.nvim_buf_set_lines(active_buf, 0, -1, false, lines)
  else -- split
    vim.cmd("botright split")
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    active_buf = buf

    -- Keymaps inside split
    vim.keymap.set("n", main_module.config.keymaps.quit, function()
      M.close_ui()
    end, { buffer = buf })

    if is_visual_search then
      vim.keymap.set("n", main_module.config.keymaps.replace, function()
        main_module.last.replace = vim.fn.input("Replace '" .. main_module.last.search .. "' with > ")
        if main_module.last.replace ~= "" then
          M.close_ui()
          main_module.show_preview(true, false)
        end
      end, { buffer = buf })
    else
      vim.keymap.set("n", main_module.config.keymaps.edit, function()
        M.close_ui()
        main_module.open_input_modal(main_module.last.search, main_module.last.replace)
      end, { buffer = buf })
    end

    vim.keymap.set("n", main_module.config.keymaps.apply_all, function()
      main_module.apply_replace(false)
      M.close_ui()
    end, { buffer = buf })

    vim.keymap.set("n", main_module.config.keymaps.one_by_one, function()
      main_module.last.current_result_index = 1
      main_module.apply_replace(true)
    end, { buffer = buf })

    vim.keymap.set("n", main_module.config.keymaps.inline_edit, function()
      vim.api.nvim_buf_set_option(active_buf, "modifiable", true)
      vim.api.nvim_command("startinsert")
    end, { buffer = buf })

    vim.keymap.set("n", main_module.config.keymaps.save_inline_edit, function()
      vim.api.nvim_buf_set_option(active_buf, "modifiable", false)
      local lines = vim.api.nvim_buf_get_lines(active_buf, 0, -1, false)
      main_module.apply_inline_edit(lines)
    end, { buffer = buf })

    vim.keymap.set("n", main_module.config.keymaps.populate_quickfix, function()
      main_module.populate_quickfix()
    end, { buffer = buf })
  end
end

function M.close_ui()
  if ripreplace.active_win and vim.api.nvim_win_is_valid(ripreplace.active_win) then
    vim.api.nvim_win_close(ripreplace.active_win, true)
  end
  ripreplace.active_win = nil
  ripreplace.active_buf = nil
end

return M
