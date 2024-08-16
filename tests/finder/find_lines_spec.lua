local finder = require("telescope._extensions.lazy_plugins.finder")
local utils = require("tests.utils")

describe("[finder.line_number_search]", function()
  it("should find single and double quotes", function()
    local case = [=[return {

      { "foo/double" },

      { 'foo/single' },
    }]=]
    local case_filepath = utils.path("foo/quotes.lua")
    local dq_search = "foo/double"
    local sq_search = "foo/single"
    local expected_dq = 3
    local expected_sq = 5

    utils.write_file(case, case_filepath)

    local out_dq, dok = finder.line_number_search(dq_search, case_filepath)
    local out_sq, sok = finder.line_number_search(sq_search, case_filepath)

    assert(dok, "Not found double quote")
    assert.equal(expected_dq, out_dq, "Wrong double quote line")
    assert(sok, "Not found single quote")
    assert.equal(expected_sq, out_sq, "Wrong single quote line")
  end)

  it("should not return the same line for the same search", function()
    local case = [=[return {
      { "foo/bar" },
      { 'foo/bar' },
    }]=]
    local case_filepath = utils.path("foo/not-repeat.lua")
    local case_search = "foo/bar"
    local expected1 = 2
    local expected2 = 3
    utils.write_file(case, case_filepath)

    local out1, found1 = finder.line_number_search(case_search, case_filepath)
    local out2, found2 = finder.line_number_search(case_search, case_filepath)

    assert(found1)
    assert(found2)
    assert.equal(expected1, out1)
    assert.equal(expected2, out2)
  end)

  it("should not find non-existing strings", function()
    local case = [=[return {
      { "foo/bar" },
      { "bar/buz" },
    }]=]
    local case_filepath = utils.path("foo/not-repeat.lua")
    local case_search = "foo/bar/buz"
    local expected = 1
    utils.write_file(case, case_filepath)

    local out, found = finder.line_number_search(case_search, case_filepath)

    assert.False(found)
    assert.equal(expected, out)
  end)
end)
