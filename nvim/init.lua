-- jdtls requires Java 21+ and reads $JAVA_HOME first.
-- Set it early so all jdtls launch paths (nvim-jdtls, lspconfig, mason auto-enable) agree.
do
	local java21 = vim.fn.trim(vim.fn.system("/usr/libexec/java_home -v 21 2>/dev/null"))
	if vim.v.shell_error == 0 and java21 ~= "" then
		vim.env.JAVA_HOME = java21
	end
end

require("config.lazy")
require("config.theme")
require("config.options")
require("config.keymaps")
require("config.lsp")
require("config.filetypes")
require("config.autocmds")

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
