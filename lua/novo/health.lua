-- `:checkhealth novo` — what is installed, what is missing, and what to
-- do about it.  A health check that only says "not found" makes the
-- reader search; each failure here names the fix.
local find = require("novo.find")

local M = {}

local start = vim.health.start or vim.health.report_start
local ok_ = vim.health.ok or vim.health.report_ok
local warn_ = vim.health.warn or vim.health.report_warn
local error_ = vim.health.error or vim.health.report_error

local INSTALL = "install the toolchain: curl -fsSL https://novo-lang.org/releases/install.sh | sh"

local function report_binary(name, what)
  local path, how = find.binary(name)
  if not path then
    error_(name .. " not found", { INSTALL, "or set $NOVO_" .. name:upper() .. " to it" })
    return nil
  end
  local version = find.version(path)
  if version then
    ok_(("%s — %s (%s, from %s)"):format(name, version, what, how))
  else
    warn_(("%s found at %s but would not answer --version"):format(name, path),
          { "it may be a stale or partial install; re-run install.sh" })
  end
  return path
end

function M.check()
  start("novo.nvim")

  local ls = report_binary("novols", "the language server")
  local dbg = report_binary("novodbg", "the debug adapter")

  if vim.fn.executable("clang") == 1 then
    ok_("clang — present; the toolchain shells out to it to compile and link")
  else
    error_("clang not found", { "novo build lowers to LLVM IR and needs clang to finish; install it from your package manager" })
  end

  start("novo.nvim — optional plugins")

  if pcall(require, "lspconfig") then
    ok_("nvim-lspconfig — present; novols is registered through it")
  elseif ls then
    ok_("nvim-lspconfig absent — novols starts through vim.lsp.start instead, which is core neovim")
  end

  if pcall(require, "dap") then
    if dbg then
      ok_("nvim-dap — present; the novo adapter is registered")
    else
      warn_("nvim-dap present but novodbg was not found", { INSTALL })
    end
  else
    warn_("nvim-dap absent — no debugging", { "install mfussenegger/nvim-dap to use novodbg" })
  end

  start("novo.nvim — highlighting")

  -- `vim.treesitter.language.add` answers true for a language nobody has
  -- ever heard of, so it cannot be the probe: the first draft of this
  -- check reported a parser present on a machine with none.  Parsing a
  -- string with the language either works or it does not.
  local has_parser = pcall(vim.treesitter.get_string_parser, "", "novo")
  if has_parser then
    ok_("a tree-sitter parser for novo is installed; the queries shipped here are in use")
  else
    warn_("no tree-sitter parser for novo", {
      "highlighting falls back to none; the queries are shipped here and take effect once a parser exists",
      ":TSInstall novo builds it from https://github.com/novolang/tree-sitter-novo, which this plugin registers",
    })
  end
end

return M
