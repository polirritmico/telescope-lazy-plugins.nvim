local Finder = require("telescope._extensions.lazy_plugins.finder")

describe("test the test execution", function()
  it("First test", function()
    local case = 1
    local expected = "2"
    local output = Finder.Foo(case)
    assert.same(expected, output)
  end)
end)
