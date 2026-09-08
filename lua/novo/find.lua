-- Where the toolchain's binaries are, and nothing about how to use them.
--
-- The plugin VENDORS NOTHING and PINS NOTHING.  A user installs novo the
-- way novo-lang.org tells them to, and this finds whatever they
-- installed: the override first, then the PATH, then the install prefix
-- `novo upgrade` points at.  The same order the VS Code extension's
-- wrapper uses, so the two editors cannot disagree about which binary
-- they are talking to.
local M = {}

local uv = vim.uv or vim.loop

local function executable(path)
  if not path or path == "" then return nil end
  local st = uv.fs_stat(path)
  if st and st.type == "file" and vim.fn.executable(path) == 1 then
    return path
  end
  return nil
end

--- Resolve one toolchain binary.
--- @param name string   "novols" or "novodbg"
--- @param override string|nil  an explicit path from setup(), highest priority
--- @return string|nil path, string|nil how  the path, and where it came from
function M.binary(name, override)
  local env = vim.env["NOVO_" .. name:upper()]           -- NOVO_NOVOLS / NOVO_NOVODBG
  local candidates = {
    { executable(override),                          "the path you gave setup()" },
    { executable(env),                               "$NOVO_" .. name:upper() },
    { executable(vim.fn.exepath(name)),              "your PATH" },
    { executable(vim.fn.expand("~/.novo/current/bin/" .. name)),
                                                     "~/.novo/current/bin (the installed toolchain)" },
  }
  for _, c in ipairs(candidates) do
    if c[1] then return c[1], c[2] end
  end
  return nil, nil
end

--- `<binary> --version`, trimmed, or nil when it will not answer.
function M.version(path)
  if not path then return nil end
  local out = vim.fn.system({ path, "--version" })
  if vim.v.shell_error ~= 0 then return nil end
  return (out:gsub("%s+$", ""))
end

return M
