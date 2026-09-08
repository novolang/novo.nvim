-- novols, the language server, over stdio.
--
-- Registered through nvim-lspconfig when it is installed, because that is
-- what a user's other language servers go through and what their
-- on_attach and capabilities are written for.  Without lspconfig the
-- same server is started by `vim.lsp.start` on the FileType event, which
-- is core neovim and needs no dependency at all — the plugin has none.
local find = require("novo.find")

local M = {}

local function root_dir(fname)
  -- A package is where novo.toml is; failing that, the git root; failing
  -- that, the file's own directory.  Never the cwd, which is whatever
  -- the user happened to open the editor in.
  local found = vim.fs.find({ "novo.toml", ".git" }, { upward = true, path = vim.fs.dirname(fname) })[1]
  if found then return vim.fs.dirname(found) end
  return vim.fs.dirname(fname)
end

function M.setup(opts)
  opts = opts or {}
  if opts.enabled == false then return end

  local cmd_path, _ = find.binary("novols", opts.cmd)
  if not cmd_path then
    -- Silent: a user who has not installed the toolchain yet gets no
    -- error on every .nv file.  `:checkhealth novo` is where that is
    -- reported, once, with what to do about it.
    return
  end

  local ok, lspconfig = pcall(require, "lspconfig")
  if ok then
    local configs = require("lspconfig.configs")
    if not configs.novols then
      configs.novols = {
        default_config = {
          cmd = { cmd_path },
          filetypes = { "novo" },
          root_dir = function(fname) return root_dir(fname) end,
          single_file_support = true,
        },
      }
    end
    lspconfig.novols.setup(opts.server or {})
    return
  end

  -- No lspconfig: core neovim's own client, same server, same roots.
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "novo",
    group = vim.api.nvim_create_augroup("NovoLsp", { clear = true }),
    callback = function(args)
      local name = vim.api.nvim_buf_get_name(args.buf)
      if name == "" then return end
      vim.lsp.start(vim.tbl_extend("keep", opts.server or {}, {
        name = "novols",
        cmd = { cmd_path },
        root_dir = root_dir(name),
      }), { bufnr = args.buf })
    end,
  })
end

return M
