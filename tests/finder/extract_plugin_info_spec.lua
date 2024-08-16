local finder = require("telescope._extensions.lazy_plugins.finder")
local utils = require("tests.utils")

describe("[finder.extract_plugin_info]", function()
  it("should get correct repo_url", function()
    local case_path = utils.path("foo/repo-url.lua")
    local case = {
      { url = "sso://uri/path/uri-foo", name = "foo" },
      { url = "sso://uri/path/uri-foo" },
      { "bar/uri-foo" },
    }
    local expected_name_1 = "foo"
    local expected_url_1 = "sso://uri/path/uri-foo"
    local expected_name_2 = "uri-foo"
    local expected_url_2 = "sso://uri/path/uri-foo"
    local expected_name_3 = "uri-foo"
    local expected_url_3 = "https://github.com/bar/uri-foo"

    utils.write_plugin_spec_file(case, case_path)
    local out1 = finder.extract_plugin_info(case[1], case_path)
    local out2 = finder.extract_plugin_info(case[2], case_path)
    local out3 = finder.extract_plugin_info(case[3], case_path)

    assert.equal(expected_name_1, out1.name)
    assert.equal(expected_url_1, out1.repo_url)
    assert.equal(expected_name_2, out2.name)
    assert.equal(expected_url_2, out2.repo_url)
    assert.equal(expected_name_3, out3.name)
    assert.equal(expected_url_3, out3.repo_url)
  end)
end)
