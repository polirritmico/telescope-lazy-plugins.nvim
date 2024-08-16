local finder = require("telescope._extensions.lazy_plugins.finder")
local utils = require("tests.utils")
local P = utils.P

describe("[finder enabled/disabled]", function()
  before_each(function() utils.clean_test_fs() end)

  it("plugin should be enabled when cond and enabled are not false", function()
    local case = {
      { "enabled/case1", cond = true, enabled = true },
      { "enabled/case2", cond = true, enabled = false },
      { "enabled/case3", cond = true, enabled = nil },
      { "enabled/case4", cond = false, enabled = true },
      { "enabled/case5", cond = false, enabled = false },
      { "enabled/case6", cond = false, enabled = nil },
      { "enabled/case7", cond = nil, enabled = true },
      { "enabled/case8", cond = nil, enabled = false },
      { "enabled/case9", cond = nil, enabled = nil },
    }
    local expected = { true, false, true, false, false, false, true, false, true }

    finder.fragments = {}
    finder.import(case, "foo")

    for i, out in pairs(finder.fragments) do
      assert.equal(expected[i], out.mod.enabled, "Assert fail for 'case" .. i .. "'")
    end
  end)

  local base_parent_case = {
    "enabled/parent",
    dependencies = {
      { "enabled/case2", cond = true, enabled = true },
      { "enabled/case3", cond = true, enabled = false },
      { "enabled/case4", cond = true, enabled = nil },
      { "enabled/case5", cond = false, enabled = true },
      { "enabled/case6", cond = false, enabled = false },
      { "enabled/case7", cond = false, enabled = nil },
      { "enabled/case8", cond = nil, enabled = true },
      { "enabled/case9", cond = nil, enabled = false },
      { "enabled/case10", cond = nil, enabled = nil },
    },
  }

  it("should be disable when parent is false", function()
    local case_filepath = utils.path("foo/parent_disabled.lua")
    local case = vim.deepcopy(base_parent_case)
    case[1] = case[1] .. "-disabled"
    case.cond = true
    case.enabled = function() return false end
    local expected = false

    utils.write_plugin_spec_file(case, case_filepath)
    local output = finder.get_plugins_data(case, nil, case_filepath)

    for i, mod in pairs(output) do
      assert.equal(expected, not mod.disabled, "Assert fail for 'case" .. i .. "'")
    end
  end)
end)
