local entry_display = require("telescope.pickers.entry_display")
local make_entry = require("telescope.make_entry")

---@param opts TelescopeLazyPluginsConfig
local function make_entry_lp(opts)
  opts = opts or {}

  ---@type function
  local displayer = entry_display.create({
    separator = " ",
    items = {
      { remaining = true },
    },
  })

  local function make_display(entry)
    return displayer({
      entry.value.name,
    })
  end

  ---@param entry LazyPluginData
  return function(entry)
    if not entry then
      return nil
    end

    return make_entry.set_default_entry_mt({
      value = entry,
      display = make_display,
      ordinal = entry.name,
      path = entry.filepath,
      lnum = entry.line,
    }, opts)
  end
end

return make_entry_lp
