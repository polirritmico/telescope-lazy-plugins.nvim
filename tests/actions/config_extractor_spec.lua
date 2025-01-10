local utils = require("tests.utils")
local lp_config_extractor = require("telescope._extensions.lazy_plugins.config_extractor")

describe("actions.extract_plugin_config", function()
  it("should get correct settings", function()
    local case = {
      "buz/plugin-opts",
      opts = {
        bar = 123,
        buz = function() return true end,
        fiz = { key = "value" },
        foo = "bar",
      },
    }
    local case_entry = { name = "plugin-opts", full_name = "buz/plugin-opts" }
    local expected = {
      "-- buz/plugin%-opts options passed into `<plugin_module>%.setup%(opts%)` by lazy%.nvim",
      "-- %(Use `q` for close%)",
      "return {",
      "  bar = 123",
      "  buz = function%(%) end, %-%- <function #1>",
      '  foo = "bar"',
      "  fiz = {",
      '    key = "value"',
      "  }",
      "}",
    }

    utils.load_plugin_in_lazy_nvim(case) -- import the spec in lazy.nvim
    local output_title, output = lp_config_extractor.get_used_plugin_options(case_entry)

    assert(output_title and output)
    assert(string.find(output_title, case_entry.name, 1, true))
    for _, expected_line in pairs(expected) do
      local founded = false
      for _, output_line in pairs(output) do
        if string.find(output_line, expected_line) then
          founded = true
          break
        end
      end
      assert(founded, string.format("Missing expected_line: %s", expected_line))
    end
  end)

  it("should not get options of disabled plugins", function()
    local case_entry = { name = "off-plugin", full_name = "buz/off-plugin", disabled = true }
    local output_title, output = lp_config_extractor.get_used_plugin_options(case_entry)

    assert(not output_title)
    assert(not output)
  end)
end)
