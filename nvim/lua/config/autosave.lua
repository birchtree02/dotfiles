-- Filetype-based autosave, driven by .editorconfig.
--
-- Neovim ships built-in editorconfig support and lets you register handlers for
-- custom properties. `autosave` is not part of the editorconfig spec, so this
-- only takes effect inside this config — but it means a project can opt in per
-- glob (i.e. per filetype) without any per-machine setup, e.g.:
--
--   # .editorconfig
--   [*.md]
--   autosave = true
--
-- The handler runs when editorconfig applies to a buffer (BufNewFile/BufReadPost)
-- and stashes the result in vim.b.autosave; the autocmds below read that flag.

require("editorconfig").properties.autosave = function(bufnr, val)
	-- editorconfig lowercases values; treat only "true" as on.
	vim.b[bufnr].autosave = val == "true"
end

local function should_save(bufnr)
	return vim.b[bufnr].autosave
		and vim.bo[bufnr].modifiable
		and vim.bo[bufnr].modified
		and not vim.bo[bufnr].readonly
		and vim.bo[bufnr].buftype == "" -- normal file-backed buffer
		and vim.api.nvim_buf_get_name(bufnr) ~= ""
end

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
	desc = "Autosave buffers that opt in via .editorconfig",
	callback = function(args)
		if should_save(args.buf) then
			-- noautocmd avoids re-triggering BufWritePre/Post churn and formatters
			-- fighting the cursor; silent keeps the "written" message out of the way.
			vim.api.nvim_buf_call(args.buf, function()
				vim.cmd("silent! noautocmd write")
			end)
		end
	end,
})
