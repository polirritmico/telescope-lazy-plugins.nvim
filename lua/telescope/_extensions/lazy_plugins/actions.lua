local action_set = require("telescope.actions.set")
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")

---Collection of plugin's actions and helpers functions to create your own
---@class TelescopeLazyPluginsActions
local lp_actions = {}

---Append the current search into Telescope history
---@param prompt_bufnr integer Telescope prompt buffer value
function lp_actions.append_to_telescope_history(prompt_bufnr)
  action_state.get_current_history():append(
    action_state.get_current_line(),
    action_state.get_current_picker(prompt_bufnr),
    false
  )
end

---Close the Telescope prompt buffer (wrapper of telescope close action)
---@param prompt_bufnr integer Telescope prompt buffer value
function lp_actions.close(prompt_bufnr)
  actions.close(prompt_bufnr)
end

---Check if the Telescope selected entry has the `field` argument. If the field
---is "repo_dir", then check that the path is valid.
---@param field LazyPluginsDataField|string LazyPluginData field of the selected entry to check.
---@return LazyPluginsData? selected_entry
function lp_actions.get_selected_entry(field)
  local selected_entry = action_state.get_selected_entry().value ---@type LazyPluginsData
  if not selected_entry[field] or selected_entry[field] == "" then
    local msg = "Missing `%s` field for `%s` from the Lazy plugin spec."
    vim.notify(string.format(msg, field, selected_entry.name), vim.log.levels.WARN)
    return
  end
  if field == "repo_dir" and not (vim.uv or vim.loop).fs_stat(selected_entry.repo_dir) then
    local msg = "Path '%s' not found. Check the plugin installation."
    if selected_entry.disabled then
      msg = "Disabled plugin: " .. msg
    end
    vim.notify(string.format(msg, selected_entry.repo_dir), vim.log.levels.WARN)
    return
  end

  return selected_entry
end

---Wrapper to use custom actions. This function get and validates the selected
---entry field, executes the passed `custom_function` in a protected call and
---returns its output.
---@param prompt_bufnr integer Telescope prompt buffer value
---@param field LazyPluginsDataField Field of `LazyPluginData` to validate the selected entry (before the custom_function call).
---@param custom_function fun(prompt_bufnr: integer, entry: LazyPluginsData, args: table?): any Custom function to execute.
---@param args table? Optional custom args.
---@return any output The output of the custom_function, nil or the error object from pcall
function lp_actions.custom_action(prompt_bufnr, field, custom_function, args)
  local selected_entry = lp_actions.get_selected_entry(field)
  if not selected_entry then
    return
  end
  local ok, output = pcall(custom_function, prompt_bufnr, selected_entry, args)
  if not ok then
    vim.notify("Error in custom action", vim.log.levels.WARN)
  end
  return output
end

---Custom picker action to open the file and move the current line at the top.
---@param prompt_bufnr integer Telescope prompt buffer value
function lp_actions.open(prompt_bufnr)
  lp_actions.append_to_telescope_history(prompt_bufnr)
  -- Open the file in a new buffer
  action_set.select(prompt_bufnr, "default")
  -- Set current line at the top position of the view
  vim.cmd(":normal! zt")
end

---Custom picker action to open the plugin README file
---@param prompt_bufnr integer Telescope prompt buffer value
function lp_actions.open_plugin_readme(prompt_bufnr)
  local entry = lp_actions.get_selected_entry("repo_dir")
  if not entry then
    return
  end

  local readme
  local standard_readme_path = entry.repo_dir .. "/README.md"
  if (vim.uv or vim.loop).fs_stat(standard_readme_path) then
    readme = standard_readme_path
  else
    ---@type TelescopeLazyPluginsFinder
    local lp_finder = require("telescope").extensions.lazy_plugins.finder
    local function find_readme(path, name, type)
      if name:sub(1, 1) ~= "." then
        if type == "file" and name:lower():match("readme") then
          readme = path
          return false
        elseif type == "directory" then
          lp_finder.ls(path, find_readme)
        end
      end
    end

    lp_finder.ls(entry.repo_dir, find_readme)
  end

  if not readme then
    vim.notify(
      entry.disabled and "Disabled plugin: " or "" .. "README file not found.",
      vim.log.levels.WARN
    )
    return
  end

  lp_actions.append_to_telescope_history(prompt_bufnr)
  actions.close(prompt_bufnr)
  vim.cmd.edit(readme)
end

---Custom picker action to open the plugin repository local clone folder
---Uses the value of the `dir` field from the Lazy plugin spec.
---@param prompt_bufnr integer Telescope prompt buffer value
function lp_actions.open_repo_dir(prompt_bufnr)
  local entry = lp_actions.get_selected_entry("repo_dir")
  if not entry then
    return
  end
  lp_actions.append_to_telescope_history(prompt_bufnr)
  actions.close(prompt_bufnr)
  -- Open the folder in a new buffer
  vim.cmd("edit " .. entry.repo_dir)
end

---Open the builtin `find_files` Telescope picker at the plugin repo dir
---@param prompt_bufnr integer Telescope prompt buffer value
function lp_actions.open_repo_find_files(prompt_bufnr)
  local entry = lp_actions.get_selected_entry("repo_dir")
  if not entry then
    return
  end

  lp_actions.append_to_telescope_history(prompt_bufnr)
  actions.close(prompt_bufnr)
  builtin.find_files({
    prompt_title = string.format("Find Files - %s", entry.name),
    cwd = entry.repo_dir,
  })
end

---Open the builtin `live_grep` Telescope picker at the plugin repo dir
---@param prompt_bufnr integer Telescope prompt buffer value
function lp_actions.open_repo_live_grep(prompt_bufnr)
  local entry = lp_actions.get_selected_entry("repo_dir")
  if not entry then
    return
  end

  local opts = { prompt_title = string.format("Live Grep - %s", entry.name) }
  local cfg_ok, cfg = pcall(require, "telescope._extensions.lazy_plugins.config")
  if cfg_ok and cfg.options and cfg.options.live_grep then
    opts = vim.tbl_deep_extend("force", opts, cfg.options.live_grep)
  end
  opts["cwd"] = entry.repo_dir

  lp_actions.append_to_telescope_history(prompt_bufnr)
  actions.close(prompt_bufnr)
  builtin.live_grep(opts)
end

local open_url_cmd = "" ---@type string|nil

---Custom picker action to open the repo url in the default browser
---@param prompt_bufnr integer Telescope prompt buffer value
function lp_actions.open_repo_url(prompt_bufnr)
  local entry = lp_actions.get_selected_entry("repo_url")
  if not entry or not open_url_cmd then
    return
  end

  if open_url_cmd == "" then
    if vim.fn.executable("xdg-open") == 1 then
      open_url_cmd = "xdg-open"
    elseif vim.fn.executable("open") == 1 then
      open_url_cmd = "open"
    elseif vim.fn.executable("start") == 1 then
      open_url_cmd = "start"
    elseif vim.fn.executable("wslview") == 1 then
      open_url_cmd = "wslview"
    else
      open_url_cmd = nil
      vim.notify(
        "Error: Missing supported url handler (xdg-open, open, start or wslview).",
        vim.log.levels.ERROR,
        { title = "Telescope Lazy Plugins" }
      )
      return
    end
  end

  actions.close(prompt_bufnr)
  local cmd_output = vim.fn.jobstart({ open_url_cmd, entry.repo_url }, { detach = true })
  if cmd_output <= 0 then
    local msg = string.format("Error opening '%s' with '%s'.", entry.repo_url, open_url_cmd)
    vim.notify(msg, vim.log.levels.ERROR, { title = "Telescope Lazy Plugins" })
  end
end

---Custom picker action to show the full generated plugin options table passed
---into the `require("plugin_name").setup(opts)` call of the selected entry.
---
---_Note: This show function placeholders, not the actual function code_
---@param prompt_bufnr integer Telescope prompt buffer value
function lp_actions.open_plugin_opts(prompt_bufnr)
  local lp_cfg_extractor = require("telescope._extensions.lazy_plugins.config_extractor")
  lp_actions.append_to_telescope_history(prompt_bufnr)
  local entry = lp_actions.get_selected_entry("name")
  if not entry then
    return
  end

  local function close_picker_fn()
    actions.close(prompt_bufnr)
  end

  local lp_opts = require("telescope._extensions.lazy_plugins.config")
  local opts = vim.tbl_get(lp_opts, "options", "actions") or {}

  lp_cfg_extractor.open_config_from_lazy_nvim(close_picker_fn, entry, opts)
end

---@param prompt_bufnr integer Telescope prompt buffer value
function lp_actions.rescan_plugins(prompt_bufnr)
  actions.close(prompt_bufnr)
  require("telescope._extensions.lazy_plugins.finder").reset()
  vim.notify("Regenerated Telescope Lazy Plugins list")
  require("telescope._extensions.lazy_plugins.picker")()
end

return lp_actions
