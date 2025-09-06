local M = { config = { ui = "float", rg_flags = "", border = "rounded", keymaps = {}, backend = "rg" } }
M.last = { search = nil, replace = nil, results = {}, current_result_index = 0, search_history = {}, replace_history = {} }
local active_win = nil
local active_buf = nil

local open_float
local build_lines

local open_ui

function open_ui(lines, is_visual_search)
  if M.config.ui == "float" then
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
        border = M.config.border,
      })

      active_buf = buf
      active_win = win

      -- Keymaps inside popup
      vim.keymap.set("n", M.config.keymaps.quit, function()
        vim.api.nvim_win_close(active_win, true)
        active_win = nil
        active_buf = nil
      end, { buffer = buf })

      if is_visual_search then
        vim.keymap.set("n", M.config.keymaps.replace, function()
          M.last.replace = vim.fn.input("Replace '" .. M.last.search .. "' with > ")
          if M.last.replace ~= "" then
            vim.api.nvim_win_close(active_win, true)
            active_win = nil
            active_buf = nil
            M.show_preview(true, false)
          end
        end, { buffer = buf })
      else
        vim.keymap.set("n", M.config.keymaps.edit, function()
          vim.api.nvim_win_close(active_win, true)
          active_win = nil
          active_buf = nil
          M.open_input_modal(M.last.search, M.last.replace)
        end, { buffer = buf })
      end

      vim.keymap.set("n", M.config.keymaps.apply_all, function()
        M.apply_replace(false)
        vim.api.nvim_win_close(active_win, true)
        active_win = nil
        active_buf = nil
      end, { buffer = buf })

      vim.keymap.set("n", M.config.keymaps.one_by_one, function()
        M.last.current_result_index = 1
        M.apply_replace(true)
      end, { buffer = buf })

      vim.keymap.set("n", M.config.keymaps.inline_edit, function()
        vim.api.nvim_buf_set_option(active_buf, "modifiable", true)
        vim.api.nvim_command("startinsert")
      end, { buffer = buf })

      vim.keymap.set("n", M.config.keymaps.save_inline_edit, function()
        vim.api.nvim_buf_set_option(active_buf, "modifiable", false)
        local lines = vim.api.nvim_buf_get_lines(active_buf, 0, -1, false)
        M.apply_inline_edit(lines)
      end, { buffer = buf })

      vim.keymap.set("n", M.config.keymaps.populate_quickfix, function()
        M.populate_quickfix()
      end, { buffer = buf })
    else -- split
      vim.cmd("botright split")
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(0, buf)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      active_buf = buf

      -- Keymaps inside split
      vim.keymap.set("n", M.config.keymaps.quit, function()
        vim.api.nvim_win_close(0, true)
        active_buf = nil
      end, { buffer = buf })

      if is_visual_search then
        vim.keymap.set("n", M.config.keymaps.replace, function()
          M.last.replace = vim.fn.input("Replace '" .. M.last.search .. "' with > ")
          if M.last.replace ~= "" then
            vim.api.nvim_win_close(0, true)
            active_buf = nil
            M.show_preview(true, false)
          end
        end, { buffer = buf })
      else
        vim.keymap.set("n", M.config.keymaps.edit, function()
          vim.api.nvim_win_close(0, true)
          active_buf = nil
          M.open_input_modal(M.last.search, M.last.replace)
        end, { buffer = buf })
      end

      vim.keymap.set("n", M.config.keymaps.apply_all, function()
        M.apply_replace(false)
        vim.api.nvim_win_close(0, true)
        active_buf = nil
      end, { buffer = buf })

      vim.keymap.set("n", M.config.keymaps.one_by_one, function()
        M.last.current_result_index = 1
        M.apply_replace(true)
      end, { buffer = buf })

      vim.keymap.set("n", M.config.keymaps.inline_edit, function()
        vim.api.nvim_buf_set_option(active_buf, "modifiable", true)
        vim.api.nvim_command("startinsert")
      end, { buffer = buf })

      vim.keymap.set("n", M.config.keymaps.save_inline_edit, function()
        vim.api.nvim_buf_set_option(active_buf, "modifiable", false)
        local lines = vim.api.nvim_buf_get_lines(active_buf, 0, -1, false)
        M.apply_inline_edit(lines)
      end, { buffer = buf })

      vim.keymap.set("n", M.config.keymaps.populate_quickfix, function()
        M.populate_quickfix()
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
    vim.keymap.set("n", M.config.keymaps.quit, function()
      vim.api.nvim_win_close(0, true)
      active_buf = nil
    end, { buffer = buf })

    if is_visual_search then
      vim.keymap.set("n", M.config.keymaps.replace, function()
        M.last.replace = vim.fn.input("Replace '" .. M.last.search .. "' with > ")
        if M.last.replace ~= "" then
          vim.api.nvim_win_close(0, true)
          active_buf = nil
          M.show_preview(true, false)
        end
      end, { buffer = buf })
    else
      vim.keymap.set("n", M.config.keymaps.edit, function()
        vim.api.nvim_win_close(0, true)
        active_buf = nil
        M.open_input_modal(M.last.search, M.last.replace)
      end, { buffer = buf })
    end

    vim.keymap.set("n", M.config.keymaps.apply_all, function()
      M.apply_replace(false)
      vim.api.nvim_win_close(0, true)
      active_buf = nil
    end, { buffer = buf })

    vim.keymap.set("n", M.config.keymaps.one_by_one, function()
      M.last.current_result_index = 1
      M.apply_replace(true)
    end, { buffer = buf })

    vim.keymap.set("n", M.config.keymaps.inline_edit, function()
      vim.api.nvim_buf_set_option(active_buf, "modifiable", true)
      vim.api.nvim_command("startinsert")
    end, { buffer = buf })

    vim.keymap.set("n", M.config.keymaps.save_inline_edit, function()
      vim.api.nvim_buf_set_option(active_buf, "modifiable", false)
      local lines = vim.api.nvim_buf_get_lines(active_buf, 0, -1, false)
      M.apply_inline_edit(lines)
    end, { buffer = buf })

    vim.keymap.set("n", M.config.keymaps.populate_quickfix, function()
      M.populate_quickfix()
    end, { buffer = buf })
  end
end
end

function build_lines(with_replace, is_visual_search)
  local header
  if with_replace then
    header = "Preview Replacements (e=edit, a=replace all, o=one-by-one, q=quit)"
  elseif is_visual_search then
    header = "Search Results (r=replace, a=replace all, o=one-by-one, q=quit)"
  else
    header = "Search Results (e=edit, a=replace all, o=one-by-one, q=quit)"
  end
  local lines = { header, "" }
  for _, res in ipairs(M.last.results) do
    local file, lnum, col, text = res:match("([^:]+):(%d+):(%d+):(.*)")
    if file and text then
      if with_replace and M.last.replace then
        local replaced = text:gsub(M.last.search, M.last.replace)
        table.insert(lines, string.format("%s:%s:%s | %s → %s", file, lnum, col, text, replaced))
      else
        table.insert(lines, string.format("%s:%s:%s | %s", file, lnum, col, text))
      end
    end
  end
  return lines
end

function M.show_preview(with_replace, is_visual_search)
  if #M.last.results == 0 then
    if active_win and vim.api.nvim_win_is_valid(active_win) then
      vim.api.nvim_win_close(active_win, true)
      active_win = nil
      active_buf = nil
    end
    return
  end
  local lines = build_lines(with_replace, is_visual_search)
  open_ui(lines, is_visual_search)
end

function M.open_input_modal(search_text, replace_text)
  search_text = search_text or M.last.search or ""
  replace_text = replace_text or M.last.replace or ""
  local search_history_index = #M.last.search_history + 1
  local replace_history_index = #M.last.replace_history + 1

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "Search:  " .. search_text,
    "Replace: " .. replace_text,
    "",
    "-- Press <CR> to search, <Esc> to cancel",
    "-- Use <Up>/<Down> for search history",
    "-- Use <C-Up>/<C-Down> for replace history",
  })

  local width = math.floor(vim.o.columns * 0.8)
  local height = 6
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = M.config.border,
  })

  local function close_and_cleanup()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    vim.cmd("stopinsert")
    pcall(vim.keymap.del, "i", "<Esc>", { buffer = buf })
    pcall(vim.keymap.del, "i", "<CR>", { buffer = buf })
    pcall(vim.keymap.del, "i", "<C-c>", { buffer = buf })
    pcall(vim.keymap.del, "i", "<Up>", { buffer = buf })
    pcall(vim.keymap.del, "i", "<Down>", { buffer = buf })
    pcall(vim.keymap.del, "i", "<C-Up>", { buffer = buf })
    pcall(vim.keymap.del, "i", "<C-Down>", { buffer = buf })
  end

  if search_text ~= "" then
    vim.api.nvim_win_set_cursor(win, { 2, 10 + #replace_text }) -- Move to replace line
  else
    vim.api.nvim_win_set_cursor(win, { 1, 10 + #search_text })
  end
  vim.cmd("startinsert")

  vim.keymap.set("i", M.config.keymaps.cancel, close_and_cleanup, { buffer = buf })

  vim.keymap.set("i", "<CR>", function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, 2, false)
    local search = vim.fn.trim(string.sub(lines[1], 10))
    local replace = vim.fn.trim(string.sub(lines[2], 10))
    if search ~= "" then
      table.insert(M.last.search_history, search)
    end
    if replace ~= "" then
      table.insert(M.last.replace_history, replace)
    end
    close_and_cleanup()
    M.show_preview(replace ~= "", false)
  end, { buffer = buf })

  vim.keymap.set("i", "d", function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, 2, false)
    local search = vim.fn.trim(string.sub(lines[1], 10))
    local replace = vim.fn.trim(string.sub(lines[2], 10))
    close_and_cleanup()
    local directory = vim.fn.input("Search in directory > ", vim.fn.getcwd(), "dir")
    if directory ~= "" then
      M.search_in_directory(search, replace, directory)
    end
  end, { buffer = buf })

  vim.keymap.set("i", "f", function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, 2, false)
    local search = vim.fn.trim(string.sub(lines[1], 10))
    local replace = vim.fn.trim(string.sub(lines[2], 10))
    close_and_cleanup()
    local files_str = vim.fn.input("Search in files (comma separated) > ")
    if files_str ~= "" then
      local files = vim.split(files_str, ",%s*")
      M.search_in_files(search, replace, files)
    end
  end, { buffer = buf })

  vim.keymap.set("i", M.config.keymaps.search_history_up, function()
    if search_history_index > 1 then
      search_history_index = search_history_index - 1
      local search = M.last.search_history[search_history_index]
      vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "Search:  " .. search })
    end
  end, { buffer = buf })

  vim.keymap.set("i", M.config.keymaps.search_history_down, function()
    if search_history_index < #M.last.search_history then
      search_history_index = search_history_index + 1
      local search = M.last.search_history[search_history_index]
      vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "Search:  " .. search })
    end
  end, { buffer = buf })

  vim.keymap.set("i", M.config.keymaps.replace_history_up, function()
    if replace_history_index > 1 then
      replace_history_index = replace_history_index - 1
      local replace = M.last.replace_history[replace_history_index]
      vim.api.nvim_buf_set_lines(buf, 1, 2, false, { "Replace: " .. replace })
    end
  end, { buffer = buf })

  vim.keymap.set("i", M.config.keymaps.replace_history_down, function()
    if replace_history_index < #M.last.replace_history then
      replace_history_index = replace_history_index + 1
      local replace = M.last.replace_history[replace_history_index]
      vim.api.nvim_buf_set_lines(buf, 1, 2, false, { "Replace: " .. replace })
    end
  end, { buffer = buf })

  vim.api.nvim_buf_attach(buf, false, {
    on_bytes = function(_, _, _, _, _, _, _, _, _, _, _, _)
      local lines = vim.api.nvim_buf_get_lines(buf, 0, 2, false)
      local search = vim.fn.trim(string.sub(lines[1], 10))
      local replace = vim.fn.trim(string.sub(lines[2], 10))
      M.live_search(search, replace)
    end,
  })
end

function M.project_search()
  local mode = vim.fn.mode()

  if mode:match("[vV]") then
    -- Visual selection: use the old workflow
    local _, ls, cs = unpack(vim.fn.getpos("'<"))
    local _, le, ce = unpack(vim.fn.getpos("'>"))
    local lines = vim.fn.getline(ls, le)
    if #lines == 0 then return end
    lines[#lines] = string.sub(lines[#lines], 1, ce)
    lines[1] = string.sub(lines[1], cs)
    local search = table.concat(lines, "\n")

    if search == "" then return end
    M.last.search = search
    M.last.replace = nil

    local cmd = get_search_command(search)
    M.last.results = vim.fn.systemlist(cmd)
    if #M.last.results == 0 then
      vim.notify("No matches found", vim.log.levels.INFO)
      return
    end

    M.show_preview(false, true)
  else
    -- Normal mode: use the new modal
    M.open_input_modal()
  end
end

function M.apply_replace(one_by_one)
  if not M.last.replace or M.last.replace == "" then return end
  if not M.last.search or #M.last.results == 0 then return end

  if one_by_one then
    local result_count = #M.last.results
    while M.last.current_result_index <= result_count do
      local res = M.last.results[M.last.current_result_index]
      local file, lnum, col, _ = res:match("([^:]+):(%d+):(%d+):(.*)")
      if file then
        vim.cmd("edit " .. file)
        vim.api.nvim_win_set_cursor(0, { tonumber(lnum), tonumber(col) - 1 })

        local choice = vim.fn.confirm("Replace '" .. M.last.search .. "' in this file?", "&Yes\n&No\n&All", 1)

        if choice == 1 then
          -- Replace and continue
          local f = io.open(file, "r")
          local content = f:read("*all")
          f:close()
          local replaced_content = content:gsub(M.last.search, M.last.replace, 1) -- Replace only the first occurrence
          f = io.open(file, "w")
          f:write(replaced_content)
          f:close()
          vim.notify("Replaced one occurrence in " .. file, vim.log.levels.INFO)
        elseif choice == 2 then
          -- Skip and continue
          vim.notify("Skipped.", vim.log.levels.INFO)
        elseif choice == 3 then
          -- Replace all and exit
          M.apply_replace(false)
          return
        end
      end
      M.last.current_result_index = M.last.current_result_index + 1
    end
    vim.notify("One-by-one replacements finished.", vim.log.levels.INFO)
    return
  end

  -- Replace all logic
  for _, res in ipairs(M.last.results) do
    local file, _, _, _ = res:match("([^:]+):(%d+):(%d+):(.*)")
    if file then
      local f = io.open(file, "r")
      if not f then goto continue end
      local content = f:read("*all")
      f:close()
      local replaced_content = content:gsub(M.last.search, M.last.replace)
      f = io.open(file, "w")
      if f then
        f:write(replaced_content)
        f:close()
      end
    end
    ::continue::
  end

  vim.notify("Replacements done!")
end

function M.populate_quickfix()
  local qf_list = {}
  for _, res in ipairs(M.last.results) do
    local file, lnum, col, text = res:match("([^:]+):(%d+):(%d+):(.*)")
    if file and text then
      table.insert(qf_list, { filename = file, lnum = tonumber(lnum), col = tonumber(col), text = text })
    end
  end
  vim.fn.setqflist(qf_list)
  vim.api.nvim_win_close(active_win, true)
  active_win = nil
  active_buf = nil
  vim.cmd("copen")
  vim.notify("Quickfix list populated!")
end

function M.apply_inline_edit(lines)
  for i, line in ipairs(lines) do
    if i > 2 then -- Skip header lines
      local file, lnum, col, old_text, new_text = line:match("([^:]+):(%d+):(%d+) | (.*) → (.*)")
      if file and new_text then
        local f = io.open(file, "r")
        if f then
          local content = f:read("*all")
          f:close()
          local file_lines = vim.split(content, "\n")
          file_lines[tonumber(lnum)] = new_text
          local new_content = table.concat(file_lines, "\n")
          f = io.open(file, "w")
          if f then
            f:write(new_content)
            f:close()
          end
        end
      end
    end
  end
  vim.api.nvim_win_close(active_win, true)
  active_win = nil
  active_buf = nil
  vim.notify("Inline edits applied!")
end

local function get_search_command(search_text, files, directory)
  local cmd
  if M.config.backend == "rg" then
    cmd = { "rg", "--vimgrep", "--no-heading" }
    for flag in string.gmatch(M.config.rg_flags, "[^%s]+") do
      table.insert(cmd, flag)
    end
    table.insert(cmd, search_text)
    if directory then
      table.insert(cmd, directory)
    end
    if files then
      table.insert(cmd, "--files-with-matches")
      for _, file in ipairs(files) do
        table.insert(cmd, file)
      end
    end
  elseif M.config.backend == "git_grep" then
    cmd = { "git", "grep", "-n", "-P" } -- -n for line numbers, -P for perl-regexp
    if directory then
      table.insert(cmd, "--untracked") -- Include untracked files
      table.insert(cmd, "--recurse-submodules") -- Recurse into submodules
      table.insert(cmd, directory)
    end
    if files then
      for _, file in ipairs(files) do
        table.insert(cmd, file)
      end
    end
    table.insert(cmd, "--") -- Separator for files
    table.insert(cmd, search_text)
  end
  return cmd
end

function M.search_in_directory(search_text, replace_text, directory)
  M.last.search = search_text
  M.last.replace = replace_text

  local cmd = get_search_command(search_text, nil, directory)

  M.last.results = vim.fn.systemlist(cmd)
  if #M.last.results == 0 then
    vim.notify("No matches found in directory " .. directory, vim.log.levels.INFO)
    return
  end
  M.show_preview(replace_text ~= "", false)
end

function M.search_in_files(search_text, replace_text, files)
  M.last.search = search_text
  M.last.replace = replace_text

  local cmd = get_search_command(search_text, files, nil)

  M.last.results = vim.fn.systemlist(cmd)
  if #M.last.results == 0 then
    vim.notify("No matches found in specified files", vim.log.levels.INFO)
    return
  end
  M.show_preview(replace_text ~= "", false)
end

function M.live_search(search_text, replace_text)
  if search_text == "" then
    if active_win and vim.api.nvim_win_is_valid(active_win) then
      vim.api.nvim_win_close(active_win, true)
      active_win = nil
      active_buf = nil
    end
    return
  end

  M.last.search = search_text
  M.last.replace = replace_text

  local cmd = get_search_command(search_text)
  M.last.results = vim.fn.systemlist(cmd)

  M.show_preview(replace_text ~= "", false)
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  M.config.keymaps = vim.tbl_deep_extend("force", {
    project_search = { "n", "v" },
    project_search_key = "<leader>rr",
    quit = "q",
    replace = "r",
    edit = "e",
    apply_all = "a",
    one_by_one = "o",
    inline_edit = "i",
    save_inline_edit = "<leader>s",
    populate_quickfix = "qf",
    search_history_up = "<Up>",
    search_history_down = "<Down>",
    replace_history_up = "<C-Up>",
    replace_history_down = "<C-Down>",
    cancel = "<C-c>",
  }, M.config.keymaps)

  vim.keymap.set(M.config.keymaps.project_search, M.config.keymaps.project_search_key, M.project_search, { desc = "Project-wide search & replace preview" })
end

return M
