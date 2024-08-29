;; extends

(
 (macro_invocation
  (scoped_identifier
     path: (identifier) @_path
     name: (identifier) @_identifier)

  (token_tree (raw_string_literal (string_content) @injection.content )))

 (#eq? @_path "sqlx")
 (#match? @_identifier "^query")
 (#set! injection.language "sql")
)

(
 (macro_invocation
  (scoped_identifier
     path: (identifier) @_path
     name: (identifier) @_identifier)

  (token_tree (string_literal (string_content) @injection.content) ))

 (#eq? @_path "sqlx")
 (#match? @_identifier "^query")
 (#set! injection.language "sql")
)
