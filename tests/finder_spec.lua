local Finder = require("telescope._extensions.lazy_plugins.finder")
local Helpers = require("tests.helpers")

describe("test the test execution", function()
  it("First test", function()
    local case = 1
    local expected = "2"
    local output = Finder.Foo(case)
    assert.same(expected, output)
  end)
end)

describe("Get configs", function()
  local rtp = vim.opt.rtp:get()
  before_each(function()
    vim.opt.rtp = rtp
    for k, v in pairs(package.loaded) do
      if k:find("^foobar") then
        package.loaded[k] = nil
      end
    end
    Helpers.fs_rmdir("")
    assert(not vim.uv.fs_stat(Helpers.path("")))
  end)
  it("import specs", function()
    local case = { import = "foo" }
    local expected = { "foo.bar", "foo.buz" }
    local output = Finder.expand_import(case)
    assert.same(expected, output)
  end)
end)
