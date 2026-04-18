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
        action = act.PasteFrom("Clipboard"),
    }
}

config.background = {
    {
        source = { File = home_dir .. "/nixos/dotfiles/assets/ghost_in_the_shell.png" },
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

config.default_prog = { "bash" }
config.color_scheme = "functional-purple"
config.initial_cols = 120
config.initial_rows = 28
config.font_size = 11

config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

local TAB_WIDTH = 18

wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
    local title = tab.tab_title
    if not title or #title == 0 then
        title = tab.active_pane.title
    end
    if not title or #title == 0 then
        local prog = tab.active_pane.foreground_process_name
        title = prog and prog:match("([^/]+)$") or "shell"
    end
    if #title > TAB_WIDTH then
        title = title:sub(1, TAB_WIDTH)
    else
        local padding = TAB_WIDTH - #title
        local left = math.floor(padding / 2)
        local right = padding - left
        title = string.rep(" ", left) .. title .. string.rep(" ", right)
    end
    return title
end)

return config
