-- Highlighting, folds and text objects.
--
-- The QUERIES ship here, under `queries/novo/`, because they are small
-- and they belong with the editor integration.  The PARSER does not:
-- `tree-sitter-novo` is built from the grammar in the toolchain's own
-- repository, and until that grammar has a repository of its own there
-- is nothing for nvim-treesitter to clone.  So this registers the
-- language and leaves installing the parser to the user, and
-- `:checkhealth novo` says plainly whether one is present.
--
-- What this does NOT do is pretend: a plugin that registered a parser
-- URL nobody can fetch would turn a missing feature into a failing
-- install.
local M = {}

function M.setup(opts)
  opts = opts or {}
  if opts.enabled == false then return end

  -- `.nv` is the `novo` filetype either way (see ftdetect), and neovim
  -- maps filetype to parser language by name, so the queries beside this
  -- file are found once a parser called `novo` exists.
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then return end

  local configs = parsers.get_parser_configs and parsers.get_parser_configs()
  if not configs or configs.novo then return end

  local url = opts.parser_url
  if not url then return end   -- nothing to clone yet; see the note above

  configs.novo = {
    install_info = { url = url, files = { "src/parser.c" }, branch = "main" },
    filetype = "novo",
  }
end

return M
