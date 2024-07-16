local utils = require("tests.utils")

describe("[Init]", function()
  it("Has correct environment for tests", function()
    for _, name in ipairs({ "config", "data", "cache", "state" }) do
      local path = utils.norm(vim.fn.stdpath(name))
      assert(path:find(".tests/" .. name, 1, true), path .. " not in .tests")
    end
  end)

  it("Can access Telescope", function()
    local tele_ok, tele = pcall(require, "telescope")
    assert(tele_ok and tele, "Can't load telescope")
  end)

  it("Can access Telescope Lazy Plugins", function()
    local _, tele = pcall(require, "telescope")
    utils.mute_notify()

    assert(tele.extensions.lazy_plugins, "Can't access Telescope Lazy Plugins")
    utils.unmute_notify()
  end)

  it("Can access Telescope Lazy Plugins Config", function()
    local cfg_ok, tlp_cfg = pcall(require, "telescope._extensions.lazy_plugins.config")
    assert(cfg_ok and tlp_cfg, "Cant access telescope.extensions.lazy_plugins.config")
  end)
end)
