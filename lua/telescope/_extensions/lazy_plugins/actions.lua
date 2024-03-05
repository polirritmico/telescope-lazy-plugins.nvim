local action_set = require("telescope.actions.set")
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")

local lp_actions = {}

---Custom picker action to open the file and move the current line at the top.
---@param prompt_bufnr integer Telescope prompt buffer value
function lp_actions.open(prompt_bufnr)
  -- Append to Telescope history
  action_state
    .get_current_history()
    :append(
      action_state.get_current_line(),
      action_state.get_current_picker(prompt_bufnr)
    )
  -- Open the file in a new buffer
  action_set.select(prompt_bufnr, "default")
  -- Set current line at the top position of the view
  vim.cmd(":normal! zt")
end

---Custom picker action to open the plugin repository local clone folder
---Uses the value of the `dir` field from the Lazy plugin spec.
---@param prompt_bufnr integer Telescope prompt buffer value
function lp_actions.open_repo_dir(prompt_bufnr)
  local entry = action_state.get_selected_entry().value ---@type LazyPluginData
  if not entry.repo_dir or entry.repo_dir == "" then
    local msg = "Missing `dir` field for `%s` from the Lazy plugin spec."
    vim.notify(string.format(msg, entry.name), vim.log.levels.WARN)
    return
  end
  -- Append to Telescope history
  action_state
    .get_current_history()
    :append(
      action_state.get_current_line(),
      action_state.get_current_picker(prompt_bufnr)
    )
  actions.close(prompt_bufnr)
  -- Open the file in a new buffer
  vim.cmd("edit " .. entry.repo_dir)
end

---Dummy function to not close Telescope from mouse clicks.
function lp_actions.nothing() end

local open_url_cmd = "" ---@type string|nil

---Custom picker action to open the repo url in the default browser
function lp_actions.open_repo_url()
  local entry = action_state.get_selected_entry()
  local repo_url = entry.value.repo_url
  if type(repo_url) ~= "string" or repo_url == "" or not open_url_cmd then
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

  local cmd_output = vim.fn.jobstart({ open_url_cmd, repo_url }, { detach = true })
  if cmd_output <= 0 then
    local msg = string.format("Error opening '%s' with '%s'.", repo_url, open_url_cmd)
    vim.notify(msg, vim.log.levels.ERROR, { title = "Telescope Lazy Plugins" })
  end
end

return lp_actions
