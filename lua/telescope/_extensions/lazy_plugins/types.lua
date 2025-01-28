---@meta

---Stores the relevant Lazy plugin spec data to use by the picker.
---@class LazyPluginsData
---@field name string Name of the plugin showed in the picker
---@field full_name string Full name of the plugin repository (account/repo)
---@field filepath string Full file path to the plugin lua configuration
---@field line integer Line number of the plugin definition in the lua file
---@field repo_url string Url to the repo
---@field repo_dir string Path to the local repository clone
---@field disabled? boolean Enabled/Disabled plugin
---@field file? string Path to the config filename showed in the picker

---Collected data from Lazy spec
---@class LazyMinSpec
---@field dir? string
---@field url? string
---@field name? string
---@field import? string|LazyMinSpec[]
---@field cond? boolean|fun():boolean
---@field enabled? boolean|fun():boolean

---@module "lazy"

---@class LazyPluginsFragment
---@field mod LazyMinSpec|LazyPluginSpec
---@field path string

---@class TelescopeLazyPluginsConfig
---@field lazy_config string? Path to the file containing the lazy opts and setup() call.
---@field mappings table Keymaps attached to the picker. See `:h telescope.mappings`.
---@field name_only boolean Match only the `repo_name`, false to match the full `account/repo_name`.
---@field picker_opts table Layout options passed into Telescope. Check `:h telescope.layout`.
---@field show_disabled boolean Also show disabled plugins from the Lazy spec.
---@field auto_rescan boolean Automatic rescan and rebuild the spec list when lazy detects a change in the config.
---@field custom_entries? (LazyPluginsCustomEntry|LazyPluginsData)[] Table to pass custom entries to the picker.
---@field live_grep? table Options to pass into the `live_grep` telescope builtin picker.
---@field ignore_imports? string[]|table<string, boolean> Array of imports to ignore.
---@field actions? LazyPluginsConfigActions Actions options.

---@class TelescopeLazyPluginsUserConfig
---@field lazy_config? string Path to the file containing the lazy opts and setup() call.
---@field mappings? table Keymaps attached to the picker. See `:h telescope.mappings`.
---@field name_only? boolean Match only the `repo_name`, false to match the full `account/repo_name`.
---@field picker_opts? table Layout options passed into Telescope. Check `:h telescope.layout`.
---@field show_disabled? boolean Also show disabled plugins from the Lazy spec.
---@field auto_rescan? boolean Automatic rescan and rebuild the spec list when lazy detects a change in the config.
---@field custom_entries? (LazyPluginsCustomEntry|LazyPluginsData)[] Table to pass custom entries to the picker.
---@field live_grep? table Options to pass into the `live_grep` telescope builtin picker.
---@field ignore_imports? string[]|table<string, boolean> Array of imports to ignore.
---@field actions? LazyPluginsConfigActions Actions options.

---@class LazyPluginsConfigActions
---@field opts_viewer? LazyPluginsActionOptsViewer

---@alias LazyPluginsActionOptsViewer
--- | "float" Default. Open the plugin config in a float window.
--- | "tab" Open the plugin config in a new tab.

---@class LazyPluginsCustomEntry
---@field name string Entry name
---@field filepath string Full file path to the lua target file
---@field line? integer Optional: Line number to set the view on the target file
---@field repo_url? string Optional: Url to open with the `open_repo_url` action
---@field repo_dir? string Optional: Directory path to open with the `open_repo_dir` action

---@alias LazyPluginsDataField
--- | "name" Name of the plugin showed in the picker
--- | "full_name" Full name of the plugin repository (account/repo)
--- | "filepath" Full file path to the plugin lua configuration
--- | "line" Line number of the plugin definition in the lua file
--- | "repo_url" Url to the repo
--- | "repo_dir" Path to the local repository clone
--- | "file" Path to the config filename showed in the picker
