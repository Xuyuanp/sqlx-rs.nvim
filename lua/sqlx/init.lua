local M = {}

local PLUGIN_NAME = 'sqlx-rs.nvim'

local default_config = {
    format_opts = {
        indent_column = true,
        strip_comments = false,
        use_space_around_operators = true,
        keyword_case = 'upper',
        identifier_case = 'lower',
        reindent = true,
        indent_after_first = false,
        wrap_after = 80,
        comma_first = true,
    },
}

---@function setup
---@param opts table | nil
function M.setup(opts)
    opts = opts or {}
    default_config = vim.tbl_extend('force', default_config, opts)

    M.script = vim.api.nvim_get_runtime_file('scripts/sqlx-format.py', false)[1]
end

---@param sql string
function M.format(sql)
    local args = vim.tbl_extend('force', default_config.format_opts, { sql = sql })
    return vim.fn.systemlist({ 'python', M.script }, vim.fn.json_encode(args))
end

---@param bufnr number | nil
function M.format_buf(bufnr)
    bufnr = bufnr or 0
    local parser = vim.F.npcall(vim.treesitter.get_parser, bufnr, 'rust')
    if not parser then
        vim.notify('Treesitter parser for rust is not installed', vim.log.levels.ERROR, { title = PLUGIN_NAME })
        return
    end
    local tree = parser:parse()[1]

    local query = vim.treesitter.query.parse(
        'rust',
        [[
(
  (macro_invocation
    (scoped_identifier
      path: (identifier) @_path
      name: (identifier) @_identifier)

    (token_tree (raw_string_literal) @raw))

  (#eq? @_path "sqlx")
  (#match? @_identifier "^query")
)
]]
    )

    for id, node, _ in query:iter_captures(tree:root(), bufnr, 0, -1) do
        if 'raw' == query.captures[id] then
            local text = vim.treesitter.get_node_text(node, bufnr)
            -- trim prefix `r#"` and suffix `"#`
            text = vim.trim(string.sub(text, 4, #text - 2))

            local formatted = M.format(text)
            if vim.v.shell_error ~= 0 then
                vim.notify(string.format('format SQL failed:\n%s', formatted), vim.log.levels.ERROR, { title = PLUGIN_NAME })
                return
            end

            local start_row, start_col, end_row, end_col = node:range()
            local rep = string.rep(' ', start_col)
            for idx, line in ipairs(formatted) do
                formatted[idx] = rep .. line
            end
            table.insert(formatted, 1, 'r#"')
            table.insert(formatted, rep .. '"#')

            vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, formatted)
        end
    end
end

return M
