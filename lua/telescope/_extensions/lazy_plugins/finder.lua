local finders = require("telescope.finders")
local lp_config = require("telescope._extensions.lazy_plugins.config")
local lp_make_entry = require("telescope._extensions.lazy_plugins.make_entry")

---@class TelescopeLazyPluginsFinder
local M = {}

M.search_history = {}
function M.add_search_history(search, file, linenr)
  if not M.search_history[file] then
    M.search_history[file] = {}
  end
  M.search_history[file][search] = linenr
end

function M.last_search_line(search, file)
  if M.search_history[file] and M.search_history[file][search] then
    return M.search_history[file][search]
  end
end

---@param repo_name string Repository name (username/plugin)
---@param filepath string Full file path
---@return integer -- Matching line number or 1
function M.line_number_search(repo_name, filepath)
  local search_str = string.format([["%s"]], repo_name)
  local from_line = M.last_search_line(search_str, filepath) or 1
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
  return 1
end

---Fast implementation to check if a table is a list
---@param obj table
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

---@type table<string, string[]>
M.unloaded_cache = {}

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

---@param opts? {cache?:boolean}
function M.get_unloaded_rtp(modname, opts)
  opts = opts or {}

  local topmod = modname:match("^[^./]+") or modname

  if opts.cache and M.unloaded_cache[topmod] then
    return M.unloaded_cache[topmod], true
  end

  local norm = M.normalize_filename(topmod)

  ---@type string[]
  local rtp = {}
  local Config = require("lazy.core.config")
  if Config.spec then
    for _, plugin in pairs(Config.spec.plugins) do
      if not (plugin._.loaded or plugin.module == false) then
        if norm == M.normalize_filename(plugin.name) then
          table.insert(rtp, 1, plugin.dir)
        else
          table.insert(rtp, plugin.dir)
        end
      end
    end
  end
  M.unloaded_cache[topmod] = rtp
  return rtp, false
end

function M.find_root(modname)
  local paths, cached = M.get_unloaded_rtp(modname, { cache = true })

  local query = {
    rtp = true,
    paths = paths,
    patterns = { ".lua", "" },
  }
  local ret = require("lazy.core.cache").find(modname, query)[1]

  if not ret and cached then
    query.rtp = false
    query.paths = M.get_unloaded_rtp(modname)
    ret = require("lazy.core.cache").find(modname, query)[1]
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
---@param fn fun(modname:string, modpath:string)
function M.lsmod(modname, fn)
  local root, match = M.find_root(modname)
  if not root then
    return
  end

  if match:sub(-4) == ".lua" then
    fn(modname, match)
    if not vim.uv.fs_stat(root) then
      return
    end
  end

  M.ls(root, function(path, name, type)
    if name == "init.lua" then
      fn(modname, path)
    elseif (type == "file" or type == "link") and name:sub(-4) == ".lua" then
      fn(modname .. "." .. name:sub(1, -5), path)
    elseif type == "directory" and vim.uv.fs_stat(path .. "/init.lua") then
      fn(modname .. "." .. name, path .. "/init.lua")
    end
  end)
end

---@param spec LazyMinSpec
function M.expand_import(spec)
  if type(spec.import) == "function" and not spec.name then
    vim.notify("import: Error missing spec.name", vim.log.levels.ERROR)
    return
  elseif type(spec.import) ~= "function" and type(spec.import) ~= "string" then
    vim.notify("import: spec.import is not string", vim.log.levels.ERROR)
    return
  end

  -- if spec.cond == false or (type(spec.cond) == "function" and not spec.cond()) then return end
  -- if spec.enabled == false or (type(spec.enabled) == "function" and not spec.enabled()) then return end

  local spec_import = spec.import

  local modspecs = {}
  if type(spec_import) == "string" then
    ---@cast spec_import string
    M.lsmod(spec_import, function(modname, modpath)
      modspecs[#modspecs + 1] = { mod = modname, path = modpath }
    end)
  else
    modspecs = { { mod = spec.import } }
  end

  for _, modspec in ipairs(modspecs) do
    local mod = type(modspec.mod) == "function" and modspec() or require(modspec.mod)
    if type(mod) ~= "table" then
      vim.notify("import: module spec is not a table")
    end
    M.import(mod, modspec.path)
  end
  return modspecs
end

---Add the spec into the fragments. If the spec has dependencies expand them
---and import them
function M.add(spec, path)
  if not path then
    error("Adding spec without path")
  end
  M.fragments[#M.fragments + 1] = { mod = spec, path = path }

  if spec.dependencies then
    M.import(spec.dependencies, path)
  end
end

---Check the spec type, expand it, import it or add it to the fragments
---@param spec string|LazyMinSpec
---@param path? string
function M.import(spec, path)
  if type(spec) == "string" then
    M.add({ spec }, path)
  elseif #spec > 1 or M.is_list(spec) then
    for _, inner_spec in pairs(spec) do
      M.import(inner_spec, path)
    end
  elseif spec[1] or spec.dir or spec.url then
    M.add(spec, path)
    if spec and spec.import then
      M.expand_import(spec)
    end
  elseif spec.import then
    M.expand_import(spec)
  else
    vim.notify("lp_finder.import: Not supported spec", vim.log.levels.ERROR)
  end
end

function M.collect_fragments()
  local lazy_specs = require("lazy.core.config").options.spec
  ---@cast lazy_specs LazyMinSpec
  M.import(lazy_specs)
end

---Convert the fragment data into a LazyPluginData
---@param mod LazyMinSpec
---@param cfg_path string
---@return LazyPluginData
function M.extract_plugin_info(mod, cfg_path)
  local repo_name = mod.name or mod[1]
  local name = repo_name:match("[^/]+$")
  local line = M.line_number_search(repo_name, cfg_path)

  local repo_url = mod.url and mod.url
    or name:sub(1, 8) == "https://" and name
    or string.format("https://github.com/%s", name)
  repo_url = repo_url:gsub("%.git$", "")

  ---@type LazyPluginData
  local plugin = {
    name = name,
    filepath = cfg_path,
    file = cfg_path:match(".*/(.*/.*)%.%w+"),
    line = line,
    repo_name = repo_name,
    repo_url = repo_url,
    repo_dir = mod.dir or "", -- TODO: Implement
  }

  return plugin
end

function M.build_plugins_collection(fragments)
  if not fragments or #fragments < 1 then
    vim.notify("Empty fragments", vim.log.levels.WARN)
    return {}
  end

  for _, fragment in pairs(fragments) do
    local plugin = M.extract_plugin_info(fragment.mod, fragment.path)
    table.insert(M.plugins_collection, plugin)
  end
end

---Get the Lazy plugin data from the Lazy specification. For each plugin,
---obtains the plugin name, repository name (<username/plugin>), full file path
---of the Lua file containing the plugin config, and the line number where the
---repository name is found.
---@return table<LazyPluginData>
function M.get_plugins_data()
  ---@diagnostic disable undefined
  if M.plugins_collection then
    return M.plugins_collection
  end

  M.fragments = {}
  M.plugins_collection = {}

  M.collect_fragments()
  M.build_plugins_collection(M.fragments)

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
