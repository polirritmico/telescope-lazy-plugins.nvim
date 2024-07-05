local M = {}

M.root_path = vim.fn.fnamemodify("./.tests/fs", ":p")

---@return string
function M.norm(path)
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

---@param files string[]
function M.fs_create(files)
  local ret = {} ---@type string[]
  for _, file in ipairs(files) do
    ret[#ret + 1] = M.norm(M.root_path .. "/" .. file)
    local parent = vim.fn.fnamemodify(ret[#ret], ":h:p")
    vim.fn.mkdir(parent, "p")
    M.write_file(ret[#ret], "")
  end
  return ret
end

function M.ls(path, fn)
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

---@param dir string
--function M.fs_rmdir(dir)
--  dir = M.norm(M.root_path .. "/" .. dir)
--  M.walk(dir, function(path, _, type)
--    if type == "directory" then
--      vim.uv.fs_rmdir(path)
--    else
--      vim.uv.fs_unlink(path)
--    end
--  end)
--  vim.uv.fs_rmdir(dir)
--end
