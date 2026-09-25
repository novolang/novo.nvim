# novo.nvim

[novo-lang](https://novo-lang.org) in neovim: the language server, the
debugger, and the highlighting queries.

```lua
-- lazy.nvim
{
  "novolang/novo.nvim",
  lazy = false,
  opts = {},
}
```

That is the whole install. It finds whatever toolchain you have and
configures nothing you did not ask for. It loads at startup rather
than on the first `.nv` buffer because `:checkhealth novo` runs the
health check shipped here, and a plugin lazy.nvim has not loaded yet
has no health check to run: with `ft = "novo"` the command answers
"No healthcheck found" until a novo file has been opened. Startup
costs nothing measurable, since the plugin registers a filetype, a
server and a parser and starts none of them.

## What you get

| | from | needs |
| --- | --- | --- |
| Diagnostics, go-to-definition, hover, completion | `novols` | the toolchain |
| Breakpoints, stepping, a variables pane | `novodbg` | the toolchain and [nvim-dap](https://github.com/mfussenegger/nvim-dap) |
| Highlighting, folds, text objects | the queries here | a `novo` tree-sitter parser |
| `.nv` recognised as `novo` | this plugin | — |

Everything degrades on its own. No toolchain and the language server
stays quiet rather than erroring on every buffer; no nvim-dap and there
is no debugging; no parser and there is no highlighting. One command
says which of those is true for you:

```
:checkhealth novo
```

It reports each binary with its version and where it was found, and
names the fix for anything missing.

Hover (`K`) on a name shows its declaration's signature and the comment
written above it, whether it is declared in the buffer, another module
of the package or a dependency, and go-to-definition opens the
declaring file, a dependency's copy in the package cache included.

## Installing the toolchain

```sh
curl -fsSL https://novo-lang.org/releases/install.sh | sh
```

The plugin looks for `novols` and `novodbg` in this order: the path you
pass to `setup()`, then `$NOVO_NOVOLS` / `$NOVO_NOVODBG`, then your
`PATH`, then `~/.novo/current/bin`, which is where `novo upgrade` keeps
the installed toolchain. It vendors nothing and pins no version, so
upgrading the toolchain is the whole update.

`novo build` shells out to `clang` to compile and link, so you need one
installed. The health check says so if you do not.

## Debugging

`novodbg` debugs a compiled binary, not a source file. Build with debug
information first:

```sh
novo build --debug src/main.nv -o main
```

Then `:lua require("dap").continue()` and pick **Debug the binary beside
this file**. It offers the binary named after the current file and lets
you correct it, rather than guessing silently.

Outside an editor, `novo debug src/main.nv` does the build and opens a
debugger in one command.

Values render the way novo prints them — a list shows its elements, an
optional reads `Some(97)` — from novo 0.8.6 onwards.

## Highlighting

The queries ship here, under `queries/novo/`, vendored from
[tree-sitter-novo](https://github.com/novolang/tree-sitter-novo). The
parser comes from that repository, and nvim-treesitter can install it:

```vim
:TSInstall novo
```

The plugin registers the grammar for you, on either line of
nvim-treesitter (the `master` branch and the `main` rewrite), so that
is the whole install. The `main` branch compiles the parser with your C
compiler and needs no tree-sitter CLI, since the repository carries
the generated sources.
If you would rather manage the parser yourself — building it from a
novo checkout with `orbit/novo-treesitter/bin/install-nvim.sh`, say —
turn the registration off:

```lua
opts = { treesitter = { parser_url = false } }
```

**Keep the parser and this plugin in step.** The queries here name
nodes from a particular version of the grammar. A parser older than the
queries fails with `Invalid node type` and gives you no highlighting at
all, rather than degrading. `:checkhealth novo` reports a missing
parser but cannot tell you about a stale one, so run `:TSUpdate novo`
after updating the plugin.

## Configuration

Defaults, all optional:

```lua
opts = {
  lsp = {
    enabled = true,
    cmd = nil,      -- an explicit path to novols
    server = {},    -- passed to lspconfig, or to vim.lsp.start without it
  },
  dap = {
    enabled = true,
    cmd = nil,            -- an explicit path to novodbg
    configurations = nil, -- replaces the default configuration entirely
  },
  treesitter = { enabled = true, parser_url = nil },
}
```

`server` is where your own `on_attach` and `capabilities` go. With
[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) installed the
server is registered through it, so it behaves like your others; without
it, core neovim's `vim.lsp.start` runs the same server on the same
roots. A package root is the nearest directory with a `novo.toml`, then
the git root, then the file's own directory — never the working
directory.

## Licence

Apache-2.0.
