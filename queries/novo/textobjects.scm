; tree-sitter-novo textobjects — slice 5c.
;
; Captures used by nvim-treesitter-textobjects (and helix's
; equivalent) for `vaf` / `vif` / `vac` / `vip` etc.  The capture
; name conventions are documented at
; https://github.com/nvim-treesitter/nvim-treesitter-textobjects.

; ── Functions ──────────────────────────────────────────────────────
; @function.outer covers the entire fn from `fn` through the close
; of its body block (so `vaf` selects fn-and-body).
; @function.inner is just the body's contents (so `vif` selects
; everything inside the fn, excluding the header).
(fn_decl) @function.outer

(fn_decl
  body: (block) @function.inner)

; ── Type definitions (struct/enum) treated as @class for parity ────
; with the standard textobjects keymap (`vac` / `vic`).
(struct_decl) @class.outer
(enum_decl)   @class.outer

; ── Parameters ─────────────────────────────────────────────────────
; `vap` / `vip` for parameter selection on fn signatures.
(param) @parameter.outer
(param
  name: (identifier) @parameter.inner)

; And on call sites — both positional and named args count as params
; from the textobject's perspective.
(named_arg) @parameter.outer
(named_arg
  value: (_) @parameter.inner)

; ── Calls ──────────────────────────────────────────────────────────
; @call.outer / @call.inner for `vac` / `vic` if remapped from
; class-style.
(call_expr) @call.outer
(call_expr
  callee: (_)
  (_)? @call.inner)

; ── Comments ───────────────────────────────────────────────────────
(line_comment) @comment.outer
