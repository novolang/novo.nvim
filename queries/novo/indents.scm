; tree-sitter-novo indents.scm
;
; Drives nvim auto-indent on Enter / Tab / Backspace.  Captures
; tell the indent engine where to add or remove indentation
; relative to the current line.

; @indent.begin  — next line indents one level deeper
; @indent.end    — next line dedents one level
; @indent.dedent — this line dedents (e.g. `else`, `elif`)

; ── Block-introducing constructs ──────────────────────────────────
; The nodes that own a `body: (block ...)` field.  The indent
; engine adds one level after the header line.
(fn_decl) @indent.begin
(struct_decl) @indent.begin
(enum_decl) @indent.begin
(trait_decl) @indent.begin
(impl_decl) @indent.begin
(state_machine_decl) @indent.begin
(register_decl) @indent.begin
(error_kind_decl) @indent.begin
(if_stmt) @indent.begin
(elif_stmt) @indent.begin
(else_stmt) @indent.begin
(for_stmt) @indent.begin
(while_stmt) @indent.begin
(loop_stmt) @indent.begin
(match_stmt) @indent.begin
(match_arm) @indent.begin
(states_block) @indent.begin
(events_block) @indent.begin
(transitions_block) @indent.begin

; ── Dedent triggers ───────────────────────────────────────────────
; `else` / `elif` should sit at the same indent as the matching
; `if` even though they're separate statements.  Without this, nvim
; auto-indents them one level too deep when the user finishes the
; if body.
(elif_stmt) @indent.dedent
(else_stmt) @indent.dedent

; ── Brackets / parens / list literals ─────────────────────────────
; Lines that end with an open bracket get the next line indented
; one level; the matching close bracket dedents.
(list_literal) @indent.begin
(struct_literal) @indent.begin
(tuple_expr) @indent.begin
(param_list) @indent.begin
