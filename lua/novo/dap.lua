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

  -- Debugging a novo program means debugging the binary the compiler
  -- produced, not the .nv source, so every configuration has to answer
  -- "which binary".  `novo build` writes it to `_novo/<stem>` and older
  -- versions wrote `<stem>` in the working directory, so look in both
  -- before asking: on the common path the debugger just starts.
  local function built_binary(prompt_only)
    return function()
      local cwd = vim.fn.getcwd()
      local stem = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t:r")
      if not prompt_only then
        for _, candidate in ipairs({ cwd .. "/_novo/" .. stem, cwd .. "/" .. stem }) do
          if vim.fn.executable(candidate) == 1 then return candidate end
        end
      end
      return vim.fn.input("Path to the compiled binary: ", cwd .. "/_novo/", "file")
    end
  end

  -- Stopping at entry is the default because a short program otherwise
  -- runs to completion before the debug UI has finished opening, which
  -- reads as "the debugger did nothing".
  dap.configurations.novo = opts.configurations or {
    {
      name = "Debug the built binary (stop at entry)",
      type = "novo",
      request = "launch",
      program = built_binary(false),
      cwd = "${workspaceFolder}",
      args = {},
      stopOnEntry = true,
    },
    {
      name = "Run the built binary (no pause)",
      type = "novo",
      request = "launch",
      program = built_binary(false),
      cwd = "${workspaceFolder}",
      args = {},
      stopOnEntry = false,
    },
    {
      name = "Debug a binary I name",
      type = "novo",
      request = "launch",
      program = built_binary(true),
      cwd = "${workspaceFolder}",
      args = {},
      stopOnEntry = true,
    },
  }
end

return M
