local Finder = require("telescope._extensions.lazy_plugins.finder")
local Utils = require("tests.utils")

describe("[Finder]", function()
  local rtp = vim.opt.rtp:get()

  before_each(function()
    vim.opt.rtp = rtp

    for k, v in pairs(package.loaded) do
      if k:find("^foobar") then
        package.loaded[k] = nil
      end
    end
    Utils.fs_rmdir("")

    -- assert(not vim.uv.fs_stat(Helpers.path("")))
  end)

  it("import specs", function()
    local case = { import = "foo" }
    local expected = { "foo.bar", "foo.buz" }
    local output = Finder.expand_import(case)
    assert.same(expected, output)
  end)
end)
