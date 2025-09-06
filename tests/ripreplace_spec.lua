describe("ripreplace", function()
  local ripreplace

  before_each(function()
    -- Mock vim global
    _G.vim = {
      api = {
        nvim_create_buf = function() return 1 end,
        nvim_win_is_valid = function() return true end,
        nvim_win_close = function() end,
        nvim_buf_set_lines = function() end,
        nvim_win_set_cursor = function() end,
        nvim_buf_attach = function() end,
        nvim_buf_get_lines = function() return { "Search: ", "Replace: " } end,
        nvim_buf_set_option = function() end,
        nvim_command = function() end,
        nvim_open_win = function() return 1 end,
      },
      fn = {
        trim = function(s) return s end,
        input = function() return "" end,
        systemlist = function() return {} end,
        getpos = function() return {0,0,0} end,
        getline = function() return "" end,
        confirm = function() return 1 end,
        setqflist = function() end,
        timer_stop = function() end,
      },
      cmd = function() end,
      notify = function() end,
      log = { levels = { INFO = 1 } },
      schedule = function(fn) fn() end,
      defer_fn = function(fn) fn() end,
      split = function(s, sep) return {} end,
      o = { columns = 80, lines = 24 },
      tbl_deep_extend = function(_, t1, t2) return vim.tbl_extend("force", t1, t2) end,
      tbl_extend = function(_, t1, t2)
        local new_t = {}
        for k, v in pairs(t1) do new_t[k] = v end
        for k, v in pairs(t2) do new_t[k] = v end
        return new_t
      end,
    }

    -- Reload ripreplace to use the mocked vim
    package.loaded["ripreplace"] = nil
    package.loaded["ripreplace.ui"] = nil
    ripreplace = require("ripreplace")
  end)

  after_each(function()
    _G.vim = nil
  end)

  it("should load the plugin", function()
    assert.is_table(ripreplace)
    assert.is_function(ripreplace.setup)
    assert.is_function(ripreplace.project_search)
    assert.is_function(ripreplace.get_search_command)
  end)

  describe("M.get_search_command", function()
    it("should return the correct rg command for basic search", function()
      ripreplace.config.backend = "rg"
      ripreplace.config.rg_flags = ""
      local cmd = ripreplace.get_search_command("test_search")
      assert.same({ "rg", "--vimgrep", "--no-heading", "test_search" }, cmd)
    end)

    it("should include rg_flags when set", function()
      ripreplace.config.backend = "rg"
      ripreplace.config.rg_flags = "-i --max-depth 5"
      local cmd = ripreplace.get_search_command("test_search")
      assert.same({ "rg", "--vimgrep", "--no-heading", "-i", "--max-depth", "5", "test_search" }, cmd)
    end)

    it("should include directory when provided", function()
      ripreplace.config.backend = "rg"
      ripreplace.config.rg_flags = ""
      local cmd = ripreplace.get_search_command("test_search", nil, "./src")
      assert.same({ "rg", "--vimgrep", "--no-heading", "test_search", "./src" }, cmd)
    end)

    it("should include files when provided", function()
      ripreplace.config.backend = "rg"
      ripreplace.config.rg_flags = ""
      local cmd = ripreplace.get_search_command("test_search", { "file1.lua", "file2.lua" }, nil)
      assert.same({ "rg", "--vimgrep", "--no-heading", "test_search", "--files-with-matches", "file1.lua", "file2.lua" }, cmd)
    end)

    it("should return the correct git_grep command for basic search", function()
      ripreplace.config.backend = "git_grep"
      local cmd = ripreplace.get_search_command("test_search")
      assert.same({ "git", "grep", "-n", "-P", "--", "test_search" }, cmd)
    end)

    it("should include directory for git_grep", function()
      ripreplace.config.backend = "git_grep"
      local cmd = ripreplace.get_search_command("test_search", nil, "./src")
      assert.same({ "git", "grep", "-n", "-P", "--untracked", "--recurse-submodules", "./src", "--", "test_search" }, cmd)
    end)

    it("should include files for git_grep", function()
      ripreplace.config.backend = "git_grep"
      local cmd = ripreplace.get_search_command("test_search", { "file1.lua", "file2.lua" }, nil)
      assert.same({ "git", "grep", "-n", "-P", "file1.lua", "file2.lua", "--", "test_search" }, cmd)
    end)
  end)
end)