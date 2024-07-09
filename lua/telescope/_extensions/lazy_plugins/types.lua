---Stores the relevant Lazy plugin spec data to use by the picker.
---@class LazyPluginsData
---@field name string Name of the plugin
---@field repo_name string Full name of the plugin repository
---@field filepath string Full file path to the plugin lua configuration
---@field line integer Line number of the plugin definition in the lua file
---@field repo_url string Url to the repo
---@field repo_dir string Path to the local repository clone
---@field enabled? boolean

---Collected data from Lazy spec
---@class LazyMinSpec
---@field dir? string
---@field url? string
---@field name? string
---@field import? string|table<LazyMinSpec>
---@field cond? boolean|fun():boolean
---@field enabled? boolean|fun():boolean

---@class LazyPluginsFragment
---@field mod LazyMinSpec
---@field path string

---@class TelescopeLazyPluginsConfig
---@field lazy_config string? Optional. Path to the file containing the lazy opts and setup() call
---@field mappings table Keymaps attached to the picker. See `:h telescope.mappings`
---@field name_only boolean Match only the `repo_name`, false to match the full `account/repo_name`
---@field picker_opts table Layout options passed into Telescope. Check `:h telescope.layout`
---@field show_disabled boolean Also show disabled plugins from the Lazy spec
---@field custom_entries? table<LazyPluginsCustomEntry|LazyPluginsData> Table to pass custom entries to the picker.
---@field live_grep? table Options to pass into the `live_grep` telescope builtin picker

---@class LazyPluginsCustomEntry
---@field name string Entry name
---@field filepath string Full file path to the lua target file
---@field line? integer Optional: Line number to set the view on the target file
---@field repo_url? string Optional: Url to open with the `open_repo_url` action
---@field repo_dir? string Optional: Directory path to open with the `open_repo_dir` action
