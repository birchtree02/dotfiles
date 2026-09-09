-- jdtls requires Java 21+ and reads $JAVA_HOME first.
-- Set it early so all jdtls launch paths (nvim-jdtls, lspconfig, mason auto-enable) agree.
do
	local java21

	-- macOS: java_home resolves versions for us.
	if vim.fn.executable("/usr/libexec/java_home") == 1 then
		local out = vim.fn.trim(vim.fn.system("/usr/libexec/java_home -v 21 2>/dev/null"))
		if vim.v.shell_error == 0 and out ~= "" then
			java21 = out
		end
	end

	-- Linux: no java_home, so glob the common JVM install locations.
	if not java21 then
		for _, pattern in ipairs({
			"/usr/lib/jvm/java-21-*", -- Amazon Corretto / OpenJDK on Amazon Linux, Fedora
			"/usr/lib/jvm/*-21-*", -- Debian/Ubuntu (java-21-openjdk-amd64, etc.)
		}) do
			for _, dir in ipairs(vim.fn.glob(pattern, false, true)) do
				if vim.fn.executable(dir .. "/bin/java") == 1 then
					java21 = dir
					break
				end
			end
			if java21 then
				break
			end
		end
	end

	if java21 then
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
