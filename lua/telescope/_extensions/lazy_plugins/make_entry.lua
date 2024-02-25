local entry_display = require("telescope.pickers.entry_display")
local make_entry = require("telescope.make_entry")

---@param opts TelescopeLazyPluginsConfig
local function make_entry_lp(opts)
  local disabled = opts and opts.show_disabled == true

  local lp_items
  if disabled then
    lp_items = {
      separator = " ",
      items = {
        { width = 0.5 },
        { width = 0.48 },
        { width = 0.2 },
      },
    }
  else
    lp_items = {
      separator = "  ",
      items = {
        { width = 0.5 },
        { width = 0.5 },
      },
    }
  end
  local displayer = entry_display.create(lp_items) ---@type function
  local hl_file = "Comment"
  local hl_enabled = "TelescopeResultsClass" -- Selection
  local hl_disabled = "Delimiter"

  local function make_display(entry)
    if not disabled then
      return displayer({
        { entry.value.name },
        { entry.value.file, hl_file },
      })
    else
      return displayer({
        { entry.value.name },
        { entry.value.file, hl_file },
        entry.value.disabled and { "○", hl_disabled } or { "●", hl_enabled },
      })
    end
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
