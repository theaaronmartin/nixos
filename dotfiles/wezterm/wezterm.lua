local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

local function get_home_dir()
	if wezterm.target_os == "Windows" then
		return os.getenv("USERPROFILE")
	else
		return os.getenv("HOME")
	end
end

local home_dir = get_home_dir()

config.keys = {
	{
		key = "V",
		mods = "CTRL|SHIFT",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		key = "v",
		mods = "CTRL",
		action = act.PasteFrom("Clipboard"),
	},
	{
		key = "v",
		mods = "CTRL",
		action = act.PasteFrom("PrimarySelection"),
	},
}

config.background = {
	{
		source = { File = home_dir .. "/Pictures/Wallpaper/ghost_in_the_shell.png" },
		width = "Cover",
		height = "Cover",
		hsb = { brightness = 0.5 },
	},
	{
		source = { Color = "rgba(29, 23, 39, 0.97)" },
		height = "100%",
		width = "100%",
	},
}

config.default_prog = { "pwsh" }
config.color_scheme = "functional-purple"
config.initial_cols = 120
config.initial_rows = 28
config.font_size = 11

config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

return config
