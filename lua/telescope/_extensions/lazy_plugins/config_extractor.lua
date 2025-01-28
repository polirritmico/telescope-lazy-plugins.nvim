---@class TelescopeLazyPluginsSpecExtractor
local PluginSpecExtractor = {}

PluginSpecExtractor.autocmd_group = vim.api.nvim_create_augroup("LazyPluginsAutocmd", {})

---@param winnr integer
---@param bufnr integer
function PluginSpecExtractor.set_close_autocmd(winnr, bufnr)
  vim.api.nvim_create_autocmd("WinLeave", {
    group = PluginSpecExtractor.autocmd_group,
    callback = function()
      pcall(function()
        vim.api.nvim_buf_delete(bufnr, { force = true })
        vim.api.nvim_win_close(winnr, false)
      end)
    end,
    once = true,
  })
end

---@param bufnr integer
---@param rhs_fn function
function PluginSpecExtractor.set_close_map(bufnr, rhs_fn)
  vim.keymap.set("n", "q", function()
    vim.defer_fn(rhs_fn, 50)
  end, {
    noremap = true,
    silent = true,
    desc = "Telescope Lazy Plugins: Close plugin config",
    buffer = bufnr,
  })
end

---Create a floating window to show the plugin's config options
---@param win_title string Window title
---@param content string[] String lines to fill the window
function PluginSpecExtractor.create_floating_window(win_title, content)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local bufnr = vim.api.nvim_create_buf(false, true)
  local winnr = vim.api.nvim_open_win(bufnr, true, {
    title = win_title,
    title_pos = "center",
    border = "rounded",
    relative = "editor",
    style = "minimal",
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    height = height,
    width = width,
  })

  -- stylua: ignore
  local close_fn = function()
    pcall(function() vim.api.nvim_del_autocmd(PluginSpecExtractor.autocmd_group) end)
    vim.cmd.close()
  end
  PluginSpecExtractor.set_close_autocmd(winnr, bufnr)
  PluginSpecExtractor.set_close_map(bufnr, close_fn)

  vim.api.nvim_set_option_value("winfixbuf", true, { win = winnr })
  vim.api.nvim_set_option_value("filetype", "lua", { buf = bufnr })
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
  vim.api.nvim_set_option_value("readonly", true, { buf = bufnr })
  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
  vim.api.nvim_win_set_cursor(winnr, { 1, 0 })
end

---Create a tab to show the plugin's config options
---@param tab_title string Tab title
---@param content string[] String lines to fill the window
function PluginSpecExtractor.create_newtab(tab_title, content)
  vim.cmd("tabnew")
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "q",
    "<Cmd>bdelete!|tabclose<CR>",
    { noremap = true, silent = true, desc = "Telescope Lazy Plugins: Close config tab" }
  )
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
  vim.api.nvim_buf_set_name(bufnr, tab_title)
  vim.api.nvim_set_option_value("filetype", "lua", { buf = bufnr })
end

---Generate a multiline string with human-readable representation of the data
---in the plugin's options.
---@param plugin_opts table Plugin options used to generate the content
---@param entry LazyPluginsData Plugin info to generate the header comment
---@return string[] -- A list of formatted lines
function PluginSpecExtractor.generate_plugin_opts_buf_content(plugin_opts, entry)
  local content = vim.split(vim.inspect(plugin_opts), "\n")
  content[1] = "return " .. content[1]

  local pattern = "<function (%d)>"
  local new_string = "function() end, -- <function #%1>"
  for i, line in ipairs(content) do
    content[i] = line:gsub(pattern, new_string)
  end
  local comment = "-- %s options passed into `<plugin_module>.setup(opts)` by lazy.nvim"
  local info = "-- (Use `q` for close)"
  table.insert(content, 1, info)
  table.insert(content, 1, string.format(comment, entry.full_name))

  return content
end

---@param entry LazyPluginsData Selected plugin in the picker
---@return string? title
---@return string[]? content
function PluginSpecExtractor.get_used_plugin_options(entry)
  if entry.disabled then
    return
  end

  -- INFO: `lazy.nvim/lua/lazy/core/loader.lua:379` uses the
  -- `plugins._.cache.opts` table into `Plugin.values` to get the full opts
  -- passed into the plugin setup call. Following those tables address in a
  -- debugger points to the `lazy.core.plugin` module to access them.

  local plugin = vim.tbl_get(require("lazy.core.config").plugins, entry.name)
  local plugin_opts = require("lazy.core.plugin").values(plugin, "opts", false)

  local title = entry.name .. " opts"
  local content = PluginSpecExtractor.generate_plugin_opts_buf_content(plugin_opts, entry)

  return title, content
end

---Get the plugin opts table used by lazy.nvim into the <plugin>.setup(opts)
---call and generates a human-readable lua table representation into a buffer
---inside a new tab or floating window.
---@param close_picker_fn function Close the picker function
---@param entry LazyPluginsData Selected plugin in the picker
---@param opts TelescopeLazyPluginsConfig
function PluginSpecExtractor.open_config_from_lazy_nvim(close_picker_fn, entry, opts)
  local title, content = PluginSpecExtractor.get_used_plugin_options(entry)
  if not title or not content then
    vim.notify(string.format("Not enabled plugin %s", entry.name), vim.log.levels.WARN)
    return
  end

  close_picker_fn()
  if vim.tbl_get(opts, "opts_viewer") == "tab" then
    PluginSpecExtractor.create_newtab(title, content)
  else
    PluginSpecExtractor.create_floating_window(title, content)
  end
end

return PluginSpecExtractor
