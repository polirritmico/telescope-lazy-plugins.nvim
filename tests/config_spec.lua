local utils = require("tests.utils")

describe("[Config]", function()
  before_each(function()
    utils.mute_notify()
  end)

  teardown(function()
    utils.unmute_notify()
  end)

  it("Check defaults correctly constructed", function()
    local tlp_cfg = require("telescope._extensions.lazy_plugins.config")
    assert(type(tlp_cfg.options) == "table")

    tlp_cfg.setup()

    -- from types @class TelescopeLazyPluginsConfig
    local expected = {
      ["lazy_config"] = "string",
      ["mappings"] = "table",
      ["name_only"] = "boolean",
      ["picker_opts"] = "table",
      ["show_disabled"] = "boolean",
      ["custom_entries"] = "table",
      ["live_grep"] = "table",
      ["ignore_imports"] = "table",
    }

    for opt_name, value_type in pairs(expected) do
      local opt = tlp_cfg.options[opt_name]
      assert.is_not_nil(opt)
      assert.equal(type(opt), value_type, "Option type missmatch: " .. opt_name)
    end
  end)

  it("create_custom_entries_from_user_config", function()
    local filepath = utils.path("foo/custom.lua")
    local case = {
      { --@class LazyPluginsCustomEntry
        name = "Foo",
        filepath = utils.path("foo/custom.lua"),
        line = 2,
        repo_url = "192.168.0.1/foo",
        repo_dir = utils.path("foo/"),
      },
    }
    ---@type LazyPluginsData
    local exp = {
      name = "Foo",
      full_name = "",
      filepath = utils.path("foo/custom.lua"),
      file = "foo/custom",
      line = 2,
      repo_url = "192.168.0.1/foo",
      repo_dir = utils.path("foo/"),
    }
    utils.write_file("return {\n foo\n }", filepath)

    local tlp_cfg = require("telescope._extensions.lazy_plugins.config")
    tlp_cfg.options.custom_entries = case
    local output = tlp_cfg.create_custom_entries_from_user_config()
    assert.are_not_equal(#output, 0, "No custom entries")

    assert.equal(exp.name, output[1].name)
    assert.equal(exp.filepath, output[1].filepath)
    assert.equal(exp.file, output[1].file)
    assert.equal(exp.line, output[1].line)
    assert.equal(exp.repo_url, output[1].repo_url)
    assert.equal(exp.repo_dir, output[1].repo_dir)
  end)
end)
