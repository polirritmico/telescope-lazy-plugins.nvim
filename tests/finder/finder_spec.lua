local Finder = require("telescope._extensions.lazy_plugins.finder")
local Utils = require("tests.utils")
local Plugin = require("lazy.core.plugin")

local P = Utils.P

describe("[Finder]", function()
  local rtp = vim.opt.rtp:get()
  before_each(function()
    vim.opt.rtp = rtp
    Utils.clean_loaded_packages()
    Utils.clean_test_fs()
    assert(not vim.uv.fs_stat(Utils.path("")), "root should be in a clean state")
  end)

  it("import specs", function()
    local fs_context = {
      {
        path = "foo/foo.lua",
        data = [=[return {
          { "foo/bar" },
          { "foo/buz", opts = {} },
        }]=],
      },
      {
        path = "foo/bar.lua",
        data = [=[return {
          { "bar/fiz", opts = {} },
          { "bar/foo", opts = {} },
        }]=],
      },
    }
    Utils.write_files(fs_context)
    local case = { import = "foo" }
    local expected = { "foo.bar", "foo.buz" }

    -- Plugin.Spec.new(case)
    Finder.fragments = {}
    Finder.import(case)
    P(Finder)

    local output = Finder.fragments
    assert.same(expected, output)
  end)
end)
