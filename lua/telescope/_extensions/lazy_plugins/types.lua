---Stores the relevant Lazy plugin spec data to use by the picker.
---@class LazyPluginData
---@field name string Plugin name
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

---@class LazyPluginFragment
---@field mod LazyMinSpec
---@field path string
