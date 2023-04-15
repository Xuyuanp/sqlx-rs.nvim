vim.api.nvim_create_user_command("SqlxFormat", function()
	require("sqlx").format_buf()
end, { desc = "format sqlx query in rust" })
