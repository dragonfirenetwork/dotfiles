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
config.color_scheme = "Catppuccin Macchiato"        -- My other favorite color scheme
-- config.font = wezterm.font("JetBrains Mono NL")     -- Customize font
config.font = wezterm.font('JetBrains Mono NL', { weight = 'Bold', italic = true })
config.font_size = 16                               -- Adjust font size as needed
default_cursor_style = "SteadyBar"                  -- Default cursor style

-- Window customization
config.window_decorations = "RESIZE"                -- Set window resizing behavior
config.enable_tab_bar = false                       -- Disable tab bar if not needed
config.window_background_opacity = 0.90             -- Set window transparency
config.macos_window_background_blur = 10            -- Set blur for macOS

-- Background customization
background = {
    {
        source = {
            File = "Users/glitchbox/Pictures/ninjas-fire.jpg",
        },
        hsb = {
            hue = 1.0,
            saturation = 1.02,
            brightness = 0.25,
        },
        width = "100%",
        height = "100%",
        veritcal_align = "Middle",
    },
    {
        source = {
            Color = "#282c35",
        },
        width = "100%",
        height = "100%",
        opacity = 0.55
    },
}

-- tab bar
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true

-- tmux status
wezterm.on("update-right-status", function(window, _)
    local SOLID_LEFT_ARROW = ""
    local ARROW_FOREGROUND = { Foreground = { Color = "#c6a0f6" } }
    local prefix = ""

    if window:leader_is_active() then
        prefix = " " .. utf8.char(0x1f30a) -- ocean wave
        SOLID_LEFT_ARROW = utf8.char(0xe0b2)
    end

    if window:active_tab():tab_id() ~= 0 then
        ARROW_FOREGROUND = { Foreground = { Color = "#1e2030" } }
    end -- arrow color based on if tab is first pane

    window:set_left_status(wezterm.format {
        { Background = { Color = "#b7bdf8" } },
        { Text = prefix },
        ARROW_FOREGROUND,
        { Text = SOLID_LEFT_ARROW }
    })
end)

-- Window management on startup
wezterm.on('gui-startup', function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    
    -- Set window size (1720x1440 for the right side of your screen)
    window:gui_window():set_inner_size(1720, 1440)

    -- Set window position (on the right side of the screen)
    -- The X position will be screen_width - window_width = 3840 - 1720 = 2120
    window:gui_window():set_position(1720, 0)  -- Adjust Y to 0 to start at the top of the screen
end)

-- Return the final configuration
return config