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
---table to continue from the next line in future searches of the same pair.
---@param repo_name string Repository name (username/plugin)
---@param filepath string Full file path
---@return integer, boolean -- Matching line number or 1, true if found string
function M.line_number_search(repo_name, filepath)
  local find = string.find
  -- search patterns for single and double quotes
  local dq_search = string.format([["%s"]], repo_name)
  local sq_search = string.format([['%s']], repo_name)

  local from_line = M.get_last_search_history(repo_name, filepath) or 1
  local current_line = 1

  local file, err = io.open(filepath)
  assert(file, err)
  for line_str in file:lines() do
    if current_line >= from_line then
      if find(line_str, dq_search, 1, true) or find(line_str, sq_search, 1, true) then
        M.add_search_history(repo_name, filepath, current_line + 1)
        file:close()
        return current_line, true
      end
    end
    current_line = current_line + 1
  end

  local msg = string.format(
    "Can't find '%s' from line %s inside the '%s' file. Use checkhealth for details.",
    repo_name,
    from_line,
    filepath
  )
  vim.notify(msg, vim.log.levels.TRACE)
  return 1, false
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

---Use fs_scandir to loop through each element inside the given path and
---execute the passed fn. If the fn returns `false`, the scan loop breaks.
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
    _type = _type or vim.uv.fs_stat(fname).type
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
    if not vim.uv.fs_stat(match) then
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
    or (type(spec.cond) == "function" and spec.cond() == false)
    or spec.enabled == false
    or (type(spec.enabled) == "function" and spec.enabled() == false)
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
    vim.notify("expand_import: Error missing spec.name", vim.log.levels.ERROR)
    return
  elseif type(spec.import) ~= "function" and type(spec.import) ~= "string" then
    vim.notify("expand_import: spec.import is not a string", vim.log.levels.ERROR)
    return
  elseif vim.tbl_get(lp_config, "options", "ignore_imports", spec.import) then
    return
  end

  local import_name = spec.name or spec.import

  -- Avoid re-importing modules
  if vim.tbl_contains(M.imported_modules_cache, import_name) then
    return
  else
    M.imported_modules_cache[#M.imported_modules_cache + 1] = import_name
  end

  local current_enabled = parent_enabled == false and false or M.is_enabled(spec)
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
      vim.notify("expand_import: module spec is not a table", vim.log.levels.ERROR)
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
  spec.enabled = parent_enabled ~= false and M.is_enabled(spec) or false
  M.fragments[#M.fragments + 1] = { mod = spec, path = path }

  if spec.dependencies then
    M.import(spec.dependencies, path, spec.enabled --[[@as boolean]])
  end
end

---Check the spec type, expand it, import it or add it to the fragments
---@param spec string|LazyMinSpec
---@param path string
---@param parent_enabled? boolean
function M.import(spec, path, parent_enabled)
  if type(spec) == "string" then
    M.add({ spec }, path, parent_enabled)
    return
  end

  -- HACK: deepcopy to ensure that old 'spec.dependencies' values are not
  -- carried over
  if type(spec) == "table" then
    spec = vim.deepcopy(spec)
    spec["recommended"] = nil -- Remove non-lazy spec field (used by lazyvim.extras)
  end

  if #spec > 1 or M.is_list(spec) then
    for _, inner_spec in pairs(spec) do
      local inner_type = type(inner_spec)
      if inner_type == "string" and not inner_spec:find("%s") then
        M.import(inner_spec, path, parent_enabled)
      elseif inner_type == "table" then
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
    vim.notify("import: Not supported spec", vim.log.levels.ERROR)
  end
end

---@param specs LazyMinSpec
---@param spec_path string
---@return LazyPluginsFragment[]
function M.collect_fragments(specs, spec_path)
  M.fragments = {}
  M.imported_modules_cache = {}
  M.import(specs, spec_path)
  return M.fragments
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
  local repo_url = mod.url
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

---@param plugin LazyPluginsData
---@param spec LazyMinSpec|LazySpecLoader
function M.get_repository_local_clone_dir(plugin, spec)
  local repo = spec.plugins[plugin.name] and spec.plugins[plugin.name].dir
    or spec.disabled[plugin.name] and spec.disabled[plugin.name].dir
    or ""
  return repo
end

---Use the collected fragments to build the list of LazyPluginsData
---@param spec LazyMinSpec|LazySpecLoader Full parsed spec
---@param show_disabled? boolean
---@return LazyPluginsData[]
function M.build_plugins_collection(spec, show_disabled)
  if not M.fragments or #M.fragments < 1 then
    vim.notify("Empty fragments", vim.log.levels.WARN)
    return {}
  end

  show_disabled = show_disabled ~= nil and show_disabled or lp_config.options.show_disabled

  for _, fragment in pairs(M.fragments) do
    if show_disabled or fragment.mod.enabled then
      local plugin = M.extract_plugin_info(fragment.mod, fragment.path)
      plugin.repo_dir = M.get_repository_local_clone_dir(plugin, spec)

      table.insert(M.plugins_collection, plugin)
    end
  end

  -- no longer needed
  M.fragments = nil
  M.imported_modules_cache = nil

  return M.plugins_collection
end

---@param collection LazyPluginsData[]
function M.add_lazy_itself(collection)
  local lazy = require("lazy.core.config")
  table.insert(collection, {
    name = "lazy.nvim",
    full_name = "folke/lazy.nvim",
    repo_url = "https://github.com/folke/lazy.nvim",
    repo_dir = lazy.me or lazy.options.root,
    filepath = lp_config.options.lazy_config,
    file = lp_config.options.lazy_config:match(".*/(.*/.*)%.%w+"),
    line = 1,
  } --[[@as LazyPluginsData]])
end

---Get the Lazy plugin data from the Lazy specification. For each plugin,
---obtains the plugin name, repository name (<username/plugin>), full file path
---of the Lua file containing the plugin config, and the line number where the
---repository name is found.
---@param config_spec? LazyMinSpec[] Defaults to require("lazy.core.config").options.spec
---@param parsed_spec? LazyMinSpec[] Defaults to require("lazy.core.config").spec
---@param spec_path? string Defaults to lp_config.options.lazy_config
---@return LazyPluginsData[]
function M.get_plugins_data(config_spec, parsed_spec, spec_path)
  if M.plugins_collection then
    return M.plugins_collection
  end

  spec_path = spec_path or vim.tbl_get(lp_config or {}, "options", "lazy_config")
  parsed_spec = parsed_spec or require("lazy.core.config").spec --[=[@as LazyMinSpec[]]=]
  config_spec = config_spec or require("lazy.core.config").options.spec --[[@as LazyMinSpec]]

  M.plugins_collection = {}
  M.collect_fragments(config_spec, spec_path)
  M.build_plugins_collection(parsed_spec)

  if vim.tbl_get(lp_config or {}, "options", "lazy_config") then
    M.add_lazy_itself(M.plugins_collection)
  end

  for _, entry in pairs(vim.tbl_get(lp_config or {}, "options", "custom_entries") or {}) do
    table.insert(M.plugins_collection, entry)
  end

  return M.plugins_collection
end

---Remove the collected data to force the rebuild of the plugins_collection
function M.reset()
  M.plugins_collection = nil
  M.search_history = {}
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
