local action_state = require("telescope.actions.state")
local action_set = require("telescope.actions.set")

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

---Dummy function to not close Telescope from mouse clicks.
function lp_actions.nothing() end

---Custom picker action to open the repo url in a browser
function lp_actions.open_repo_url()
  local entry = action_state.get_selected_entry()
  local repo_url = entry.value.repo_url
  if type(repo_url) ~= "string" or repo_url == "" then
    return
  end

  local cmd
  if vim.fn.executable("xdg-open") == 1 then
    cmd = "xdg-open"
  elseif vim.fn.executable("open") == 1 then
    cmd = "open"
  elseif vim.fn.executable("start") == 1 then
    cmd = "start"
  elseif vim.fn.executable("wslview") == 1 then
    cmd = "wslview"
  else
    vim.notify(
      "Error: Missing supported url handler (xdg-open, open, start, wslview).",
      vim.log.levels.ERROR,
      { title = "Telescope Lazy Plugins" }
    )
    return
  end

  local cmd_output = vim.fn.jobstart({ cmd, repo_url }, { detach = true })
  if cmd_output <= 0 then
    local msg = string.format(
      "Error opening '%s' with '%s':\nreturn '%d'",
      repo_url,
      cmd,
      cmd_output
    )
    vim.notify(msg, vim.log.levels.ERROR, { title = "Telescope Lazy Plugins" })
  end
end

return lp_actions