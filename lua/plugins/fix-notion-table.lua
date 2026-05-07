return {
	event = "VeryLazy",
	config = function()
		vim.api.nvim_create_user_command("FixNotionTable", function()
			local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, "<"))
			local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, ">"))

			if start_line > end_line then
				start_line, end_line = end_line, start_line
				start_col, end_col = end_col, start_col
			end

			local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
			local result = {}

			for i, line in ipairs(lines) do
				if line:match("^%s*|") then
					table.insert(result, line)
				else
					if #result > 0 then
						result[#result] = result[#result] .. "<br>" .. vim.trim(line)
					else
						table.insert(result, line)
					end
				end
			end

			vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, result)
		end, { range = true })
	end,
}
