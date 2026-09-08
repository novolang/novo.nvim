; tree-sitter-novo folds.scm
;
; Foldable regions in nvim — `zo`/`zc`/`zM`/`zR` etc.  Each
; capture marks a node whose source range becomes a fold.

; ── Top-level decls ───────────────────────────────────────────────
(fn_decl) @fold
(struct_decl) @fold
(enum_decl) @fold
(trait_decl) @fold
(impl_decl) @fold
(state_machine_decl) @fold
(register_decl) @fold
(error_kind_decl) @fold

; ── Control-flow blocks ───────────────────────────────────────────
(if_stmt) @fold
(elif_stmt) @fold
(else_stmt) @fold
(for_stmt) @fold
(while_stmt) @fold
(loop_stmt) @fold
(match_stmt) @fold
(match_arm) @fold

; ── Block / multi-line literals ──────────────────────────────────
(block) @fold
(block_comment) @fold
(list_literal) @fold
(struct_literal) @fold
