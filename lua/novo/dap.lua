-- novodbg, the debug adapter, over stdio.
--
-- nvim-dap is optional: without it this does nothing and says so in
-- `:checkhealth novo`, rather than failing on startup for a user who
-- only wanted the language server.
local find = require("novo.find")

local M = {}

function M.setup(opts)
  opts = opts or {}
  if opts.enabled == false then return end

  local ok, dap = pcall(require, "dap")
  if not ok then return end

  local cmd_path, _ = find.binary("novodbg", opts.cmd)
  if not cmd_path then return end

  dap.adapters.novo = {
    type = "executable",
    command = cmd_path,
    -- novodbg speaks DAP on stdio and drives gdb underneath; its own
    -- logs go to stderr, which nvim-dap shows in the repl.
  }

  -- One configuration, and it asks for the program rather than guessing.
  -- A .nv file is not the thing you debug: `novo build --debug` produces
  -- the binary, and `novo debug` is the one-command path for people who
  -- are not in an editor.  The default answers the common case — the
  -- binary beside the file, named after it — without hiding the field.
  dap.configurations.novo = opts.configurations or {
    {
      name = "Debug the binary beside this file",
      type = "novo",
      request = "launch",
      program = function()
        local src = vim.api.nvim_buf_get_name(0)
        local guess = src:gsub("%.nv$", "")
        return vim.fn.input("Path to the compiled binary: ", guess, "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
  }
end

return M
