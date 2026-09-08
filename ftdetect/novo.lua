-- `.nv` is novo.  Set before anything else so the LSP autocommand and
-- the tree-sitter language both have a filetype to hang on.
--
-- The shebang pattern catches a novo script with no extension at all,
-- which `novo run` accepts and which people do write; matching on the
-- interpreter line is the only way to know what such a file is.
vim.filetype.add({
  extension = { nv = "novo" },
  pattern = { ["^#!.*/novo$"] = "novo" },
})
