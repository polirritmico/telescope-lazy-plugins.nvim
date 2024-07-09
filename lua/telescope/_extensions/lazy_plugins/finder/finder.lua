local finders = require("telescope.finders")
local lp_config = require("telescope._extensions.lazy_plugins.config")
local lp_make_entry = require("telescope._extensions.lazy_plugins.make_entry")

---@class TelescopeLazyPluginsFinder
local M = {}

M.search_history = {}

---@param search string
---@param file string
---@param linenr integer
function M.add_search_history(search, file, linenr)
  if not M.search_history[file] then
    M.search_history[file] = {}
  end
  M.search_history[file][search] = linenr
end

---@param search string
---@param file string
---@return integer?
function M.get_last_search_history(search, file)
  if M.search_history[file] and M.search_history[file][search] then
    return M.search_history[file][search]
  end
end

---Search the line number of the `repo_name` inside the target file. The function
---stores the search pair (`repo_name`/`filepath`) into the `M.search_history`
---table to continue from that line in future searches of the same pair.
---@param repo_name string Repository name (username/plugin)
---@param filepath string Full file path
---@return integer -- Matching line number or 1
function M.line_number_search(repo_name, filepath)
  local search_str = string.format([["%s"]], repo_name)
  local from_line = M.get_last_search_history(search_str, filepath) or 1
  local current_line = 1
  for line_str in io.lines(filepath) do
    if current_line > from_line then
      if string.find(line_str, search_str, 1, true) then
        M.add_search_history(search_str, filepath, current_line)
        return current_line
      end
    end
    current_line = current_line + 1
  end
  local msg = string.format(
    "Can't find '%s' from line %s inside the '%s' file. Maybe a duplicate fragment.",
    repo_name,
    from_line,
    filepath
  )
  vim.notify(msg, vim.log.levels.WARN)
  return 1
end

---Fast implementation to check if a table is a list
---@param obj table
---@return boolean
function M.is_list(obj)
  local i = 0
  for _ in pairs(obj) do
    i = i + 1
    if obj[i] == nil then
      return false
    end
  end
  return true
end

---@param filename string
---@return string
function M.normalize_filename(filename)
  local ret = filename
    :lower()
    :gsub("^n?vim%-", "")
    :gsub("%.n?vim$", "")
    :gsub("%.lua", "")
    :gsub("[^a-z]+", "")
  return ret
end

---@type table<string, string[]>
M.rtp_cache = {}

---@param opts? {cache?:boolean}
function M.get_unloaded_rtp(modname, opts)
  opts = opts or {}

  local topmod = modname:match("^[^./]+") or modname
  if opts.cache and M.rtp_cache[topmod] then
    return M.rtp_cache[topmod], true
  end

  local norm = M.normalize_filename(topmod)

  ---@type string[]
  local rtp = {}
  local lazy_cfg = require("lazy.core.config")
  if lazy_cfg.spec then
    for _, plugin in pairs(lazy_cfg.spec.plugins) do
      ---@diagnostic disable: undefined-field
      if not (plugin._.loaded or plugin.module == false) then
        if norm == M.normalize_filename(plugin.name) then
          table.insert(rtp, 1, plugin.dir)
        else
          table.insert(rtp, plugin.dir)
        end
      end
    end
  end
  M.rtp_cache[topmod] = rtp
  return rtp, false
end

function M.find_root(modname)
  local lazy_find = require("lazy.core.cache").find

  local paths, cached = M.get_unloaded_rtp(modname, { cache = true })
  local ret = lazy_find(modname, {
    rtp = true,
    paths = paths,
    patterns = { ".lua", "" },
  })[1]

  if not ret and cached then
    ret = lazy_find(modname, {
      rtp = false,
      paths = M.get_unloaded_rtp(modname),
      patterns = { ".lua", "" },
    })[1]
  end
  if ret then
    return ret.modpath:gsub("%.lua$", ""), ret.modpath
  end
end

---@param path string
---@param fn fun(path: string, name:string, type:FileType):boolean?
function M.ls(path, fn)
  local handle = vim.uv.fs_scandir(path)
  while handle do
    local name, _type = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end

    local fname = path .. "/" .. name
    _type = _type and _type or vim.uv.fs_stat(fname).type
    ---@cast _type string
    if fn(fname, name, _type) == false then
      break
    end
  end
end

---@param modname string
---@return LazyPluginsFragment[] modspecs
function M.lsmod(modname)
  local modspecs = {}
  local function add_modspec(mod, modpath)
    modspecs[#modspecs + 1] = { mod = mod, path = modpath }
  end

  local root, match = M.find_root(modname)
  if not root then
    return {}
  end

  if match:sub(-4) == ".lua" then
    add_modspec(modname, match)
    if not vim.uv.fs_stat(root) then
      return {}
    end
  end

  M.ls(root, function(path, name, type)
    if name == "init.lua" then
      add_modspec(modname, path)
    elseif (type == "file" or type == "link") and name:sub(-4) == ".lua" then
      add_modspec(modname .. "." .. name:sub(1, -5), path)
    elseif type == "directory" and vim.uv.fs_stat(path .. "/init.lua") then
      add_modspec(modname .. "." .. name, path .. "/init.lua")
    end
  end)

  return modspecs
end

---Returns `false` if the plugin is disabled or `true` otherwise.
---@param spec LazyMinSpec|LazyPluginSpec
function M.is_enabled(spec)
  if
    spec.cond == false
    or (type(spec.cond) == "function" and not spec.cond())
    or spec.enabled == false
    or (type(spec.enabled) == "function" and not spec.enabled())
  then
    return false
  end
  return true
end

---Import/Read the spec.import modules and pass them into the import function,
---while preserving a `parent_enabled = false` state for the inner module specs.
---@param spec LazyMinSpec
---@param parent_enabled? boolean
function M.expand_import(spec, parent_enabled)
  if type(spec.import) == "function" and not spec.name then
    vim.notify("import: Error missing spec.name", vim.log.levels.ERROR)
    return
  elseif type(spec.import) ~= "function" and type(spec.import) ~= "string" then
    vim.notify("import: spec.import is not string", vim.log.levels.ERROR)
    return
  end

  local import_name = spec.name or spec.import

  -- Avoid re-importing modules
  if vim.tbl_contains(M.imported_modules, import_name) then
    return
  end
  M.imported_modules[#M.imported_modules + 1] = import_name

  parent_enabled = parent_enabled == nil and true or parent_enabled
  local current_enabled = not parent_enabled and false or M.is_enabled(spec)
  spec.enabled = current_enabled

  local modspecs = {}
  if type(import_name) == "string" then
    modspecs = M.lsmod(import_name)
  else
    modspecs = { { mod = spec.import } }
  end

  for _, modspec in ipairs(modspecs) do
    local mod = type(modspec.mod) == "function" and modspec.mod() or require(modspec.mod)
    if type(mod) ~= "table" then
      vim.notify("import: module spec is not a table")
    end
    M.import(mod, modspec.path, current_enabled)
  end
  return modspecs
end

---Add the spec into the fragments. If the spec has dependencies expand them
---and import them
---@param spec LazyMinSpec|LazyPluginSpec
---@param path string
---@param parent_enabled? boolean
function M.add(spec, path, parent_enabled)
  if not path then
    error("Adding spec without path")
  end
  if spec.enabled == nil and parent_enabled ~= nil then
    spec.enabled = parent_enabled
  end
  M.fragments[#M.fragments + 1] = { mod = spec, path = path }

  if spec.dependencies then
    M.import(spec.dependencies, path, M.is_enabled(spec))
  end
end

---Check the spec type, expand it, import it or add it to the fragments
---@param spec string|LazyMinSpec
---@param path string
---@param parent_enabled? boolean
function M.import(spec, path, parent_enabled)
  if type(spec) == "string" then
    M.add({ spec }, path, parent_enabled)
  elseif #spec > 1 or M.is_list(spec) then
    for _, inner_spec in pairs(spec) do
      local inner_type = type(inner_spec)
      if inner_type == "table" or inner_type == "string" and not inner_spec:find("%s") then
        M.import(inner_spec, path, parent_enabled)
      end
    end
  elseif spec[1] or spec.dir or spec.url then
    M.add(spec, path, parent_enabled)
    if spec and spec.import then
      M.expand_import(spec, parent_enabled)
    end
  elseif spec.import then
    M.expand_import(spec, parent_enabled)
  else
    vim.notify("lp_finder.import: Not supported spec", vim.log.levels.ERROR)
  end
end

function M.collect_fragments()
  local lazy_specs = require("lazy.core.config").options.spec
  ---@cast lazy_specs LazyMinSpec
  M.fragments = {}
  M.imported_modules = {}
  M.import(lazy_specs, lp_config.options.lazy_config)
end

---Convert the fragment LazyMinSpec data into a LazyPluginData
---@param mod LazyMinSpec
---@param cfg_path string
---@return LazyPluginsData
function M.extract_plugin_info(mod, cfg_path)
  -- Full name of the plugin repository (usually account/repo) displayed if opts.name_only = false.
  local full_name = mod.name or mod[1] or mod.dir or mod.url
  -- Short name of the plugin displayed by default
  local name = mod.name or full_name:match("[^/]+$")
  local line = M.line_number_search(full_name, cfg_path)
  local repo_url = mod.url and mod.url
    or full_name:match("^http[s]?://") and full_name
    or string.format("https://github.com/%s", full_name)
    or mod.dir and mod.dir
    or ""
  local disabled = not mod.enabled

  ---@type LazyPluginsData
  local plugin = {
    disabled = disabled,
    file = cfg_path:match(".*/(.*/.*)%.%w+"),
    filepath = cfg_path,
    line = line,
    name = name,
    repo_dir = "",
    full_name = full_name,
    repo_url = repo_url,
  }

  return plugin
end

---Use the collected fragments to build the list of LazyPluginsData
function M.build_plugins_collection()
  if not M.fragments or #M.fragments < 1 then
    vim.notify("Empty fragments", vim.log.levels.WARN)
    return {}
  end

  local lazy_spec = require("lazy.core.config").spec

  for _, fragment in pairs(M.fragments) do
    local plugin = M.extract_plugin_info(fragment.mod, fragment.path)
    plugin.repo_dir = lazy_spec.plugins[plugin.name] and lazy_spec.plugins[plugin.name].dir
      or lazy_spec.disabled[plugin.name] and lazy_spec.disabled[plugin.name].dir
      or ""
    table.insert(M.plugins_collection, plugin)
  end

  -- no longer needed
  M.fragments = nil
  M.imported_modules = nil
end

---Get the Lazy plugin data from the Lazy specification. For each plugin,
---obtains the plugin name, repository name (<username/plugin>), full file path
---of the Lua file containing the plugin config, and the line number where the
---repository name is found.
---@return LazyPluginsData[] M.plugins_collection
function M.get_plugins_data()
  if M.plugins_collection then
    return M.plugins_collection
  end

  M.plugins_collection = {}
  M.collect_fragments()
  M.build_plugins_collection()

  if lp_config.options.lazy_config then
    local lazy = require("lazy.core.config")
    ---@type LazyPluginsData
    local lazy_data = {
      name = "lazy.nvim",
      full_name = "folke/lazy.nvim",
      repo_url = "https://github.com/folke/lazy.nvim",
      repo_dir = lazy.me or lazy.options.root,
      filepath = lp_config.options.lazy_config,
      file = lp_config.options.lazy_config:match("[^/]+$"),
      line = 1,
    }
    table.insert(M.plugins_collection, lazy_data)
  end

  for _, entry in pairs(lp_config.options.custom_entries) do
    table.insert(M.plugins_collection, entry)
  end

  return M.plugins_collection
end

---Finder to use with the Telescope API. Get the plugin data for each plugin
---registered on the Lazy spec.
function M.finder(opts)
  opts = vim.tbl_deep_extend("force", {}, lp_config.options, opts or {})

  return finders.new_table({
    results = M.get_plugins_data(),
    entry_maker = lp_make_entry(opts),
  })
end

return M
