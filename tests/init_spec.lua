local Utils = require("tests.utils")

describe("[Init]", function()
  it("Has correct environment for tests", function()
    for _, name in ipairs({ "config", "data", "cache", "state" }) do
      local path = Utils.norm(vim.fn.stdpath(name))
      assert(path:find(".tests/" .. name, 1, true), path .. " not in .tests")
    end
  end)
end)
