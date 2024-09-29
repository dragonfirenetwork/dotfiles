-- Pull in the wezterm API
local wezterm = require "wezterm"
local mux = wezterm.mux  -- Required for window/pane management

-- This table will hold the configuration
local config = {}

-- In newer version of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- General settings
-- config.color_scheme = "Dracula (Official)"          -- Make sure you copied the Dracula theme to the ~/.config/wezterm/colors/ directory
-- config.color_scheme = "Catppuccin Macchiato"        -- My other favorite color scheme
config.color_scheme = 'Tokyo Night (Gogh)'
-- config.font = wezterm.font("JetBrains Mono NL")     -- Customize font
config.font = wezterm.font('JetBrains Mono')
config.font_size = 15                               -- Adjust font size as needed
default_cursor_style = "BlinkingBar"                  -- Default cursor style

-- Window customization
config.window_decorations = "RESIZE"                -- Set window resizing behavior
config.enable_tab_bar = false                       -- Disable tab bar if not needed
-- config.window_background_opacity = 0.90             -- Set window transparency
-- config.macos_window_background_blur = 10            -- Set blur for macOS

-- Background
config.window_background_image = '$HOME/Wallpaper/ninjas-fire.jpg' -- Set background image

-- tab bar
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true

-- Mouse
pane_focus_follows_mouse = true

-- Keybindings
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 } -- Leader is the same as prefix in tmux
config.keys = {
    -- Pane splitting
    {
      mods   = "LEADER",
      key    = "=",
      action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }
    },
    {
      mods   = "LEADER",
      key    = "-",
      action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }
    },

    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}},
    -- Make Option-Right equivalent to Alt-f; forward-word
    {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},
}

-- Window management on startup
wezterm.on('gui-startup', function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})

    -- Set the command to run neofetch when the terminal starts
    -- pane:send_text("neofetch\n")
    
    -- Set window size (1720x1440 for the right side of your screen)
    window:gui_window():set_inner_size(1720, 1440)

    -- Set window position (on the right side of the screen)
    -- The X position will be screen_width - window_width = 3840 - 1720 = 2120
    window:gui_window():set_position(1720, 0)  -- Adjust Y to 0 to start at the top of the screen
end)

-- Return the final configuration
return config
