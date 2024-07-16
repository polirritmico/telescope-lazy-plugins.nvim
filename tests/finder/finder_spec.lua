local finder = require("telescope._extensions.lazy_plugins.finder")
local utils = require("tests.utils")

describe("[finder.line_number_search]", function()
  it("Single and double quotes", function()
    local case = [=[return {

      { "foo/double" },

      { 'foo/single' },
    }]=]
    local case_filepath = utils.path("foo/quotes.lua")
    local dq_search = "foo/double"
    local sq_search = "foo/single"
    local expected_dq = 3
    local expected_sq = 5

    utils.write_file(case, case_filepath) -- would run path again?

    local out_dq, dok = finder.line_number_search(dq_search, case_filepath)
    local out_sq, sok = finder.line_number_search(sq_search, case_filepath)

    assert(dok, "Not found double quote")
    assert.equal(expected_dq, out_dq, "Wrong double quote line")
    assert(sok, "Not found single quote")
    assert.equal(expected_sq, out_sq, "Wrong single quote line")
  end)
end)
