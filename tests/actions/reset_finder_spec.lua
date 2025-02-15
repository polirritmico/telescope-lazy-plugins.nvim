local finder = require("telescope._extensions.lazy_plugins.finder")
local utils = require("tests.utils") ---@type LazyPluginsTestUtils

describe("actions.reset_plugins_list", function()
  it("should remove history and collected new plugins", function()
    local case_before = { { "foo/bar1", opts = { buz = "fiz" } } }
    local expected_before = "foo/bar1"

    local case_path = utils.path("foo/reset-finder.lua")
    local parsed_spec, output
    utils.write_plugin_spec_file(case_before, case_path)
    parsed_spec = utils.load_plugin_in_lazy_nvim(case_before)

    finder.get_plugins_data(case_before, parsed_spec, case_path)
    assert(#finder.plugins_collection > 0)
    output = utils.get_plugin_entry_from_finder_collection(finder, case_before)
    assert.equal(expected_before, output and output.full_name)

    ---------------------------------------------------------------------------

    local case_after = {
      { "foo/bar1", opts = { buz = "fiz" } },
      { "foo/bar2", opts = { buz = "buz" } },
    }
    local expected_after = { "foo/bar1", "foo/bar2" }
    utils.write_plugin_spec_file(case_after, case_path)
    output = utils.get_plugin_entry_from_finder_collection(finder, case_before)
    parsed_spec = utils.load_plugin_in_lazy_nvim(case_after, true)

    assert.equal(expected_before, output and output.full_name)
    finder.reset()
    finder.get_plugins_data(case_after, parsed_spec, case_path)

    local output1 = utils.get_plugin_entry_from_finder_collection(finder, case_after[1])
    local output2 = utils.get_plugin_entry_from_finder_collection(finder, case_after[2])
    assert.equal(expected_after[1], output1 and output1.full_name)
    assert.equal(expected_after[2], output2 and output2.full_name)
  end)
end)
