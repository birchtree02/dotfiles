-- Macro recording indicator.
--
-- noice's default routes skip the msg_showmode event, which is where Neovim's
-- native "recording @q" text lives — so with noice active there's no visible cue
-- that a macro is being recorded. Surface it as a notification instead: a
-- persistent toast while recording, replaced by a short-lived one when it stops.
--
-- reg_recording() holds the register on RecordingEnter; on RecordingLeave it is
-- already cleared, so read v:event.regname there instead.

local rec_notif

local function macro_notify(msg, level, replace)
	local ok, notify = pcall(require, "notify")
	if not ok then
		vim.notify(msg, level)
		return nil
	end
	return notify(msg, level, {
		title = "Macro",
		timeout = replace and 1200 or false, -- persist while recording, fade after
		hide_from_history = true,
		replace = replace,
	})
end

vim.api.nvim_create_autocmd("RecordingEnter", {
	desc = "Notify while recording a macro",
	callback = function()
		rec_notif = macro_notify("● recording @" .. vim.fn.reg_recording(), vim.log.levels.WARN)
	end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
	desc = "Replace the recording notification when the macro is done",
	callback = function()
		macro_notify("✓ recorded @" .. vim.v.event.regname, vim.log.levels.INFO, rec_notif)
		rec_notif = nil
	end,
})
