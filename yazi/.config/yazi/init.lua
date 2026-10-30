-- Show git status signs next to files (signs and colors are in theme.toml under [git])
require("git"):setup({
	-- Order of status signs showing in the linemode
	order = 1500,
})
