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
    term = "wezterm",
    show_close_tab_button_in_tabs = false,
    scrollback_lines = 100000,
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
        -- and make CTRL-Click open hyperlinks
        {
            event = { Up = { streak = 1, button = 'Left' } },
            mods = 'CTRL',
            action = act.OpenLinkAtMouseCursor,
        },
    },
    keys = {
        {
            key = 'w',
            mods = 'CTRL',
            action = act.CloseCurrentTab { confirm = true },
        },
    }
}
for i = 1, 8 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = 'ALT',
        action = act.ActivateTab(i - 1),
    })
end
return config
