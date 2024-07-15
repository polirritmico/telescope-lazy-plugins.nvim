local lp_actions = require("telescope._extensions.lazy_plugins.actions")
local lp_highlights = require("telescope._extensions.lazy_plugins.highlights")

local M = {}

---@type TelescopeLazyPluginsConfig
local defaults = {
  name_only = true, -- match only the `repo_name`, false to match the full `account/repo_name`.
  show_disabled = true, -- also show disabled plugins from the Lazy spec.
  lazy_config = vim.fn.stdpath("config") .. "/lua/config/lazy.lua", -- path to the file containing the lazy opts and setup() call.
  custom_entries = {}, ---@type table<LazyPluginsCustomEntry> Table to pass custom entries to the picker.
  live_grep = {}, -- Options to pass into the `live_grep` telescope builtin picker.
  ignore_imports = {}, -- Add imports you want to ignore, e.g., "lazyvim.plugins".
  mappings = {
    ["i"] = {
      ["<C-g>x"] = lp_actions.open_repo_url,
      ["<C-g>r"] = lp_actions.open_repo_dir,
      ["<C-g>l"] = lp_actions.open_repo_live_grep,
    },
    ["n"] = {
      ["gx"] = lp_actions.open_repo_url,
      ["gr"] = lp_actions.open_repo_dir,
      ["gl"] = lp_actions.open_repo_live_grep,
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
  if not lazy_cfg or not (vim.uv or vim.loop).fs_stat(lazy_cfg) then
    local msg = "telescope-lazy-plugins: lazy_config file cannot be accessed: '%s'."
    vim.notify(string.format(msg, lazy_cfg), vim.log.levels.WARN)
  end
  M.options.lazy_config = lazy_cfg

  M.fix_non_unix_paths()

  if type(M.options.custom_entries) == "table" and #M.options.custom_entries > 0 then
    M.options.custom_entries = M.create_custom_entries_from_user_config()
  end

  if #M.options.ignore_imports > 0 then
    M.options.ignore_imports = M.array_to_lookup_table(M.options.ignore_imports)
  end

  lp_highlights.setup()
end

function M.fix_non_unix_paths()
  if not vim.uv.os_uname().version:match("Windows") then
    return
  end

  M.options.lazy_config = M.options.lazy_config:gsub("\\", "/")

  if type(M.options.custom_entries) == "table" and #M.options.custom_entries > 0 then
    for _, entry in pairs(M.options.custom_entries) do
      if entry.filepath then
        entry.filepath = entry.filepath:gsub("\\", "/")
      end
    end
  end
end

function M.array_to_lookup_table(array_tbl)
  local lookup_table = {}
  for _, value in pairs(array_tbl) do
    lookup_table[value] = true
  end
  return lookup_table
end

---@return table<LazyPluginsData>
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
