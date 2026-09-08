-- novo.nvim — novo-lang in neovim.
--
--   require("novo").setup()
--
-- Everything is optional and everything degrades: no toolchain, no
-- language server, and the plugin stays quiet rather than erroring on
-- every buffer; no nvim-dap, no debugging; no tree-sitter parser, no
-- highlighting.  `:checkhealth novo` is the one place that says which of
-- those is true for you.
local M = {}

M.defaults = {
  lsp = { enabled = true, cmd = nil, server = {} },
  dap = { enabled = true, cmd = nil, configurations = nil },
  treesitter = { enabled = true, parser_url = nil },
}

function M.setup(opts)
  local cfg = vim.tbl_deep_extend("force", M.defaults, opts or {})
  require("novo.lsp").setup(cfg.lsp)
  require("novo.dap").setup(cfg.dap)
  require("novo.treesitter").setup(cfg.treesitter)
  M.config = cfg
end

return M
