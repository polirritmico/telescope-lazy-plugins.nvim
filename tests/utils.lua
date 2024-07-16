local M = {}

M.fs_root = vim.fn.fnamemodify("./.tests/fs", ":p")

---@return string
function M.norm(path)
  assert(type(path) == "string")
  if path:sub(1, 1) == "~" then
    local home = vim.uv.os_homedir()
    assert(home, "vim.uv.os_homedir return nil")
    if home:sub(-1) == "\\" or home:sub(-1) == "/" then
      home = home:sub(1, -2)
    end
    path = home .. path:sub(2)
  end
  path = path:gsub("\\", "/"):gsub("/+", "/")
  return path:sub(-1) == "/" and path:sub(1, -2) or path
end

---@param files table<{ path: string, data: string }>
function M.write_files(files)
  for _, file in pairs(files) do
    M.write_file(file.data, file.path)
  end
end

---@param data string
---@param path string
function M.write_file(data, path)
  path = M.path(path)
  -- print("[write] " .. path)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local file = assert(io.open(path, "w"))
  file:write(data)
  file:close()
end

---@param path string
---@param fn function
function M.ls(path, fn)
  path = M.norm(path)
  local handle = vim.uv.fs_scandir(path)
  while handle do
    local name, _type = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end
    local fname = path .. "/" .. name
    if fn(fname, name, _type or vim.uv.fs_stat(fname).type) == false then
      break
    end
  end
end

---Apply the passed function
---@param path string
---@param fn fun(path: string, name:string, type:string)
function M.walk(path, fn)
  M.ls(path, function(child, name, type)
    if type == "directory" then
      M.walk(child, fn)
    end
    fn(child, name, type)
  end)
end

---@param path string
function M.path(path)
  if path:sub(1, #M.fs_root) == M.fs_root then
    return path
  end
  return M.norm(M.fs_root .. "/" .. path)
end

function M.clean_loaded_packages()
  for k, _ in pairs(package.loaded) do
    if k:find("^foobar") then
      package.loaded[k] = nil
    end
  end
end

function M.clean_test_fs()
  M.fs_rmdir("")
end

---@param dir string
function M.fs_rmdir(dir)
  -- vim.notify("executing fs_rmdir")
  dir = M.norm(M.fs_root .. "/" .. dir)
  M.walk(dir, function(path, _, type)
    if type == "directory" then
      vim.uv.fs_rmdir(path)
    else
      vim.uv.fs_unlink(path)
    end
  end)
  vim.uv.fs_rmdir(dir)
end

function M.P(...)
  local args = { ... }
  local mapped = {}
  for _, variable in pairs(args) do
    table.insert(mapped, vim.inspect(variable))
  end
  print(unpack(mapped))
  return unpack(args)
end

return M
