local finder = require("telescope._extensions.lazy_plugins.finder")
local utils = require("tests.utils") --[[@as LazyPluginsTestUtils]]

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

  it("should not raise 'too many open files error' (>256|512 files)", function()
    ---@param total_specs integer Number of mock specs to generate
    ---@param case_path string Path to write the generated spec files
    ---@return table
    local function generate_mock_specs_and_write_files(total_specs, case_path)
      local inner_spec_opts = {}
      for i = 1, 10, 1 do
        inner_spec_opts["opt" .. i] = i
      end

      local mock_specs = {}
      for i = 1, total_specs do
        local spec_filepath = string.format("%s/spec-%s.lua", case_path, i)
        local bar_spec = { "foo/bar" .. i, opts = inner_spec_opts }
        local buz_spec = { "foo/buz", enabled = true }

        mock_specs[#mock_specs + 1] = { bar_spec, spec_filepath }
        mock_specs[#mock_specs + 1] = { buz_spec, spec_filepath }

        utils.write_plugin_spec_file({ bar_spec, buz_spec }, spec_filepath)
      end
      return mock_specs
    end

    local total_specs = 600
    local case_path = utils.path("multiple-specs")
    local expected_foo_line = 14

    local mock_specs = generate_mock_specs_and_write_files(total_specs, case_path)
    local counter = 0
    for _, spec in pairs(mock_specs) do
      local plugin = finder.extract_plugin_info(spec[1], spec[2])

      if string.find(plugin.name, "bar.*") then
        counter = counter + 1
        assert.equal("bar" .. counter, plugin.name)
      else
        assert.equal(expected_foo_line, plugin.line)
      end
    end
    assert.equal(total_specs, counter)
  end)
end)
