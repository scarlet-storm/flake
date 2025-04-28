local rosepine = require('lua/rose-pine')
local act = wezterm.action
local config = {
    colors = rosepine.main.colors(),
    font = wezterm.font_with_fallback {
        "Rec Mono Semicasual",
    },
    show_tab_index_in_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,
    -- front_end = "WebGpu",
    default_prog = { "nu", "-i" },
    mouse_bindings = {
        {
            event = { Up = { streak = 1, button = 'Left' } },
            mods = 'NONE',
            action = act.CompleteSelection 'PrimarySelection',
        },
        {
            event = { Up = { streak = 2, button = 'Left' } },
            mods = 'NONE',
            action = act.CompleteSelection 'PrimarySelection',
        },
        {
            event = { Up = { streak = 3, button = 'Left' } },
            mods = 'NONE',
            action = act.CompleteSelection 'PrimarySelection',
        },
    }
}
return config
