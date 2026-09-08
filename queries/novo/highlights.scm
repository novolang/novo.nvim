; tree-sitter-novo highlights — slice 2/4 stub.
;
; Maps grammar nodes to the tree-sitter standard capture names that
; nvim, helix, and other editors translate to highlight groups.
; Slice 5 grows this as the grammar covers more productions.

; ── Comments ───────────────────────────────────────────────────────
(line_comment) @comment
(block_comment) @comment
(doc_comment) @comment.documentation
(shebang) @keyword.directive

; ── Keywords ───────────────────────────────────────────────────────
[
  "use"
  "let"
  "var"
  "mut"
  "async"
  "await"
  "as"
  "const"
  "register"
  "field"
  "at"
  "error_kind"
  "states"
  "events"
  "transitions"
  "frame"
  "prompt"
  "unsafe_discharge"
  "weak"
  "dyn"
  "functional"
  "nfr"
  "constraint"
] @keyword

; `else`, `pass`, `break`, `continue` are single-token rules so
; tree-sitter elides them as anonymous nodes — match the named
; rule instead.
(pass_stmt) @keyword
(break_stmt) @keyword
(continue_stmt) @keyword

; `else` doesn't surface as an anonymous token (the else_stmt
; rule has only that one terminal so tree-sitter optimises away
; the standalone token).  Match the whole node instead.
[
  "if"
  "elif"
  "match"
] @keyword.conditional

(else_stmt) @keyword.conditional

[
  "for"
  "while"
  "loop"
  "in"
] @keyword.repeat

[
  "return"
] @keyword.return

[
  "fn"
] @keyword.function

[
  "struct"
  "enum"
  "trait"
  "impl"
  "state_machine"
  ; The type-alias keyword (SPEC §3.10).  `alias` is the one spelling;
  ; `type` is reserved but never a declaration, so it is not a node
  ; this grammar produces and cannot be matched here.
  "alias"
] @keyword.type

; Compound assignment operators — colour as @operator.assignment
; for editors that distinguish from plain @operator.
[
  "+="
  "-="
  "*="
  "/="
  "%="
  "|="
  "&="
  "^="
  "<<="
  ">>="
  ">>>="
] @operator

; `for` shows up in two roles: as a loop binder (`for x in xs`)
; and as the trait-target marker in `impl Trait for Type`.  In the
; latter we want a more specific colour but tree-sitter queries
; can't easily distinguish — keep the loop colour for both.

; ── Punctuation ────────────────────────────────────────────────────
[
  "("
  ")"
  "["
  "]"
] @punctuation.bracket

[
  ","
  ":"
  "."
] @punctuation.delimiter

; Punctuation-form operators.
[
  "->"
  "=>"
  "="
  "?"
  "@"
  "+"
  "-"
  "*"
  "/"
  "%"
  "**"
  "=="
  "!="
  "<"
  ">"
  "<="
  ">="
  "||"
  "&&"
  "!"
  "|>"
  "??"
  "?."
  ; Bitwise and shift (SPEC §6 levels 8-11).
  "&"
  "|"
  "^"
  "~"
  "<<"
  ">>"
  ">>>"
] @operator

; Word-form logical operators bind to @keyword.operator so colour
; schemes that treat them like `if`/`else` (typical for languages
; that spell `and`/`or` as words) get consistent treatment.
[
  "and"
  "or"
  "not"
] @keyword.operator

; ── Literals ───────────────────────────────────────────────────────
(string_literal) @string

; F-strings: outer literal + plain text segments highlight as
; @string; `${...}` interpolations as @string.special so colour
; schemes can distinguish the embedded-expr boundary from the
; surrounding text body.
(fstring_literal) @string
(fstring_segment) @string
(fstring_interp) @string.special
(fstring_format_spec) @string.special

(integer_literal) @number
(float_literal) @number.float
(char_literal) @character
(bool_literal) @boolean
(none_literal) @constant.builtin

; ── Function declarations ──────────────────────────────────────────
(fn_decl
  name: (identifier) @function)

(param
  name: (identifier) @variable.parameter)

; ── Calls ──────────────────────────────────────────────────────────
(call_expr
  callee: (identifier) @function.call)

(call_expr
  callee: (field_access
            (identifier)
            (identifier) @function.call))

; ── Type names ─────────────────────────────────────────────────────
; Convention: PascalCase identifiers in type position are types.
; Slice 5 introduces a typed AST node for this rather than a regex.
(named_type
  (identifier) @type
  (#match? @type "^[A-Z]"))

; Type names in struct / enum decls.
(struct_decl
  name: (identifier) @type)

(enum_decl
  name: (identifier) @type)

; Effects (currently captured as plain identifiers inside [..]).
; They look like keywords in source so colour them as such.
(effect_list
  (identifier) @keyword.modifier)

; Attribute name following @.
(attribute
  (identifier) @attribute)

; ── Use paths ──────────────────────────────────────────────────────
(use_decl
  path: (module_path
          (identifier) @module))

; Named-argument labels (`Circle(radius: 5.0)`).
(named_arg
  name: (identifier) @variable.member)

; Requirement IDs and DSL highlights.
(req_id) @constant
(req_decl
  category: _ @keyword)
(req_field
  key: (identifier) @property)

; Const decl name + frame name.
(const_decl
  name: (identifier) @constant)
(frame_decl
  name: (identifier) @type)
(prompt_decl
  name: (identifier) @function)

; Struct-field labels (`x: Float`).
(struct_field
  name: (identifier) @variable.member)

; Struct literal type name (`Foo { ... }`) — colour as type.
(struct_literal
  type: (identifier) @type)

; Struct literal field labels.
(struct_literal_field
  name: (identifier) @variable.member)

; trait + impl decl names colour as types.
(trait_decl
  name: (identifier) @type.definition)
(impl_decl
  subject: (named_type
    (identifier) @type))
(impl_decl
  target: (named_type
    (identifier) @type))

; ── Patterns ────────────────────────────────────────────────────────
(wildcard_pattern) @character.special

; First identifier in a constructor pattern is the constructor name
; (Some, Circle, etc.) — colour as a type.
(constructor_pattern
  .
  (identifier) @type)

; Pattern-position binders (`Some(x)` — `x` is the binder).
(identifier_pattern
  (identifier) @variable.parameter)

; ── Special expressions ────────────────────────────────────────────
(self_expr) @variable.builtin
(self_param) @variable.builtin
(null_expr) @constant.builtin

; ── Identifiers (catch-all, lowest precedence) ────────────────────
(identifier) @variable
