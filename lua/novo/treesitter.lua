-- Highlighting, folds and text objects.
--
-- The QUERIES ship here, under `queries/novo/`, vendored from
-- novolang/tree-sitter-novo.  They are a COPY, and the copy has to move
-- with the grammar: a keyword the grammar learns is still rendered as a
-- variable until the queries here learn it too, and a query naming a
-- node an older parser does not have aborts highlighting outright
-- rather than degrading.  Re-vendor them whenever the grammar moves.
--
-- The PARSER comes from that repository, which nvim-treesitter clones
-- and builds; `:TSInstall novo` is the whole install.
local M = {}

function M.setup(opts)
  opts = opts or {}
  if opts.enabled == false then return end

  -- Registering the language is not the same as USING it: neovim starts
  -- tree-sitter per buffer, and nothing does that on its own for a
  -- filetype no plugin manager installed a parser for.  A hand-rolled
  -- config that predated this plugin had exactly this line and it is why
  -- highlighting worked there; without it the queries shipped here would
  -- sit unused and the plugin would look broken to anyone who had a
  -- parser.  pcall because a parser may not be installed, in which case
  -- there is nothing to start and nothing to say — `:checkhealth novo`
  -- is where that is reported.
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "novo",
    group = vim.api.nvim_create_augroup("NovoTreesitter", { clear = true }),
    callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
  })

  -- `.nv` is the `novo` filetype either way (see ftdetect), and neovim
  -- maps filetype to parser language by name, so the queries beside this
  -- file are found once a parser called `novo` exists.
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then return end

  local configs = parsers.get_parser_configs and parsers.get_parser_configs()
  if not configs or configs.novo then return end

  local url = opts.parser_url
  if not url then return end

  configs.novo = {
    -- scanner.c is NOT optional: novo is indentation-based, and the
    -- external scanner is what emits INDENT, DEDENT and NEWLINE.  A
    -- parser built from parser.c alone links, loads, and then fails to
    -- parse anything with a block in it.
    install_info = {
      url = url,
      files = { "src/parser.c", "src/scanner.c" },
      branch = "main",
    },
    filetype = "novo",
  }
end

return M
