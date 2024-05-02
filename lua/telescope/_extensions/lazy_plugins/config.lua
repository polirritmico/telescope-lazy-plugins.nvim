local lp_actions = require("telescope._extensions.lazy_plugins.actions")
local lp_highlights = require("telescope._extensions.lazy_plugins.highlights")

---@class TelescopeLazyPluginsConfig
---@field lazy_config string? Optional. Path to the file containing the lazy opts and setup() call
---@field lazy_spec_table string? Optional. Path to the file containing the lazy plugin spec table
---@field mappings table Keymaps attached to the picker. See `:h telescope.mappings`
---@field name_only boolean Match only the `repo_name`, false to match the full `account/repo_name`
---@field picker_opts table Layout options passed into Telescope. Check `:h telescope.layout`
---@field show_disabled boolean Also show disabled plugins from the Lazy spec
---@field custom_entries? table<LazyPluginsCustomEntry|LazyPluginData> Table to pass custom entries to the picker.
---@field live_grep? table Options to pass into the `live_grep` telescope builtin picker

---@class LazyPluginsCustomEntry
---@field name string Entry name
---@field filepath string Full file path to the lua target file
---@field line? integer Optional: Line number to set the view on the target file
---@field repo_url? string Optional: Url to open with the `open_repo_url` action
---@field repo_dir? string Optional: Directory path to open with the `open_repo_dir` action

local M = {}

---@type TelescopeLazyPluginsConfig
local defaults = {
  name_only = true, -- match only the `repo_name`, false to match the full `account/repo_name`
  show_disabled = true, -- also show disabled plugins from the Lazy spec.
  lazy_config = vim.fn.stdpath("config") .. "/lua/config/lazy.lua", -- path to the file containing the lazy opts and setup() call.
  lazy_spec_table = vim.fn.stdpath("config") .. "/lua/config/lazy.lua", -- path to the file containing the lazy plugin spec table.
  custom_entries = {}, ---@type table<LazyPluginsCustomEntry> Table to pass custom entries to the picker.
  live_grep = {}, -- Options to pass into the `live_grep` telescope builtin picker.
  mappings = {
    ["i"] = {
      ["<C-g>x"] = lp_actions.open_repo_url,
      ["<C-g>r"] = lp_actions.open_repo_dir,
      ["<C-g>l"] = lp_actions.open_repo_live_grep,
      -- HACK: Add a dummy function to avoid closing the picker on a mouse click
      ["<LeftMouse>"] = lp_actions.nothing, -- Set to `false` to fallback to the default telescope setting
    },
    ["n"] = {
      ["gx"] = lp_actions.open_repo_url,
      ["gr"] = lp_actions.open_repo_dir,
      ["gl"] = lp_actions.open_repo_live_grep,
      ["<LeftMouse>"] = lp_actions.nothing, -- Set to `false` to fallback to the default telescope setting
    },
  },
  picker_opts = {
    sorting_strategy = "ascending",
    layout_strategy = "flex",
    layout_config = {
      flex = { flip_columns = 150 },
      horizontal = { preview_width = { 0.55, max = 100, min = 30 } },
      vertical = { preview_cutoff = 20, preview_height = 0.5 },
    },
  },
}

M.options = M.options or {}

---@param opts TelescopeLazyPluginsConfig?
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", defaults, M.options, opts or {})

  local lazy_cfg = vim.fn.expand(M.options.lazy_config)
  local spec_tbl = vim.fn.expand(M.options.lazy_spec_table)
  M.options.lazy_config = vim.fn.filereadable(lazy_cfg) == 1 and lazy_cfg or nil
  M.options.lazy_spec_table = vim.fn.filereadable(spec_tbl) == 1 and spec_tbl or nil

  if type(M.options.custom_entries) == "table" and #M.options.custom_entries > 0 then
    M.options.custom_entries = M.create_custom_entries_from_user_config()
  end

  lp_highlights.setup()
end

---@return table<LazyPluginData>
function M.create_custom_entries_from_user_config()
  local function check_errors(entry)
    if not entry.name or type(entry.name) ~= "string" or entry.name == "" then
      return true
    end
    if entry.filepath and vim.fn.filereadable(entry.filepath) ~= 1 then
      return true
    end
    if entry.repo_dir and vim.fn.isdirectory(entry.repo_dir) ~= 1 then
      return true
    end
    return false
  end

  local custom_entries = {}
  for _, entry in pairs(M.options.custom_entries) do
    if check_errors(entry) then
      -- HACK: Avoid repeated warning messages: https://github.com/nvim-telescope/telescope.nvim/issues/2659
      if not M.raw_custom_entries then
        M.raw_custom_entries = vim.deepcopy(M.options.custom_entries) -- Used by checkhealth
        vim.notify(
          "[telescope-lazy-plugins] Errors detected in custom_entries.\n"
            .. "Run ':checkhealth telescope' for more details.",
          vim.log.levels.WARN
        )
      end
      return {}
    end
    entry["file"] = entry.file or entry.filepath:match(".*/(.*/.*)%.%w+")
    entry.line = entry.line or 1
    table.insert(custom_entries, entry)
  end
  return custom_entries
end

return M
