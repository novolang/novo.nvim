; tree-sitter-novo locals.scm
;
; Drives nvim-treesitter-textobjects' `@local.scope` capture used
; by `vas` (visual select around scope) and the highlight-locals
; / go-to-definition flows that derive scope info from queries.

; ── Scopes ─────────────────────────────────────────────────────────
; A new scope opens at every block construct.  Naming the
; capture `@local.scope` matches the upstream textobjects
; convention.

(fn_decl)            @local.scope
(closure_expr)       @local.scope
(impl_decl)          @local.scope
(trait_decl)         @local.scope
(struct_decl)        @local.scope
(enum_decl)          @local.scope
(state_machine_decl) @local.scope
(if_stmt)            @local.scope
(elif_stmt)          @local.scope
(else_stmt)          @local.scope
(for_stmt)           @local.scope
(while_stmt)         @local.scope
(loop_stmt)          @local.scope
(match_stmt)         @local.scope
(match_arm)          @local.scope
(block)              @local.scope

; ── Definitions ────────────────────────────────────────────────────
; Identifiers introduced by these constructs.  Captures bind the
; symbol so go-to-definition / locals-aware highlighting can
; resolve.

(fn_decl
  name: (identifier) @local.definition.function)

(param
  name: (identifier) @local.definition.parameter)

(let_stmt
  name: (identifier) @local.definition.var)

(for_stmt
  binder: (identifier_pattern
    (identifier) @local.definition.var))

(struct_decl
  name: (identifier) @local.definition.type)

(enum_decl
  name: (identifier) @local.definition.type)

(trait_decl
  name: (identifier) @local.definition.type)

(state_machine_decl
  name: (identifier) @local.definition.type)

(closure_params
  (identifier) @local.definition.parameter)

; ── References ─────────────────────────────────────────────────────
; Every identifier-position use that ISN'T a definition.  Listed
; last so the more-specific definition captures take precedence.

(identifier) @local.reference
