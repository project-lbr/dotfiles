-- Show git status signs next to files
-- (theme overrides must be set before setup, which reads them)
---@diagnostic disable-next-line: inject-field
th.git = th.git or {}
th.git.clean_sign = "✓ "

require("git"):setup({
	-- Order of status signs showing in the linemode
	order = 1500,
})
