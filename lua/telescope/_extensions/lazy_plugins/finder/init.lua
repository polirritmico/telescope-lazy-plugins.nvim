local lazy_version = tonumber(require("lazy.core.config").version:sub(1, 2))

if lazy_version < 11 then
  return require("telescope._extensions.lazy_plugins.finder.finder_old")
else
  return require("telescope._extensions.lazy_plugins.finder.finder")
end
