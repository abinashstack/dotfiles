local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ==========================================================
--  CATPPUCCIN MOCHA PALETTE (for reference in custom styling)
-- ==========================================================
local mocha = {
  rosewater = "#f5e0dc",
  flamingo  = "#f2cdcd",
  pink      = "#f5c2e7",
  mauve     = "#cba6f7",
  red       = "#f38ba8",
  maroon    = "#eba0ac",
  peach     = "#fab387",
  yellow    = "#f9e2af",
  green     = "#a6e3a1",
  teal      = "#94e2d5",
  sky       = "#89dceb",
  sapphire  = "#74c7ec",
  blue      = "#89b4fa",
  lavender  = "#b4befe",
  text      = "#cdd6f4",
  subtext1  = "#bac2de",
  subtext0  = "#a6adc8",
  overlay2  = "#9399b2",
  overlay1  = "#7f849c",
  overlay0  = "#6c7086",
  surface2  = "#585b70",
  surface1  = "#45475a",
  surface0  = "#313244",
  base      = "#1e1e2e",
  mantle    = "#181825",
  crust     = "#11111b",
}

-- ==========================================================
--  COLOR SCHEME
-- ==========================================================
config.color_scheme = "Catppuccin Mocha"

-- ==========================================================
--  FONT  — Nerd Font for icons, colorful font rules
-- ==========================================================
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium" })
config.font_size = 18.0
config.line_height = 1.15
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

-- Colorful font rules: bold, italic, bold+italic each get a unique font weight
config.font_rules = {
  {
    intensity = "Bold",
    italic = false,
    font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Bold" }),
  },
  {
    intensity = "Normal",
    italic = true,
    font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium", italic = true }),
  },
  {
    intensity = "Bold",
    italic = true,
    font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Bold", italic = true }),
  },
  {
    intensity = "Half",
    italic = false,
    font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Light" }),
  },
}

-- ==========================================================
--  WINDOW  — translucent + blur, no title bar
-- ==========================================================
config.window_background_opacity = 0.90
config.macos_window_background_blur = 30
config.window_decorations = "RESIZE"
config.initial_cols = 120
config.initial_rows = 30
config.window_padding = {
  left = 16,
  right = 16,
  top = 16,
  bottom = 10,
}

-- Subtle gradient overlaid on the background
config.background = {
  {
    source = { Color = mocha.base },
    width = "100%",
    height = "100%",
    opacity = 0.90,
  },
  {
    source = {
      Gradient = {
        colors = { mocha.crust, mocha.base, mocha.mantle },
        orientation = "Vertical",
        interpolation = "Linear",
        blend = "Rgb",
        noise = 40,
      },
    },
    width = "100%",
    height = "100%",
    opacity = 0.30,
  },
}

-- ==========================================================
--  TAB BAR  — retro style with powerline arrows
-- ==========================================================
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.status_update_interval = 1000

-- Tab bar colors + vibrant ANSI palette
config.colors = {
  foreground = mocha.text,
  background = mocha.base,

  -- Vibrant ANSI colors (more saturated than default Catppuccin)
  ansi = {
    mocha.surface1,  -- black
    "#ff6e6e",       -- red (bright cherry)
    "#69ff94",       -- green (neon mint)
    "#f0c674",       -- yellow (warm gold) -- yellow (warm gold)
    "#7aa2f7",       -- blue (electric blue)
    "#d6a0ff",       -- magenta (vivid purple)
    "#56d4dd",       -- cyan (vivid teal)
    mocha.subtext1,  -- white
  },
  brights = {
    mocha.overlay0,  -- bright black
    "#ff9e9e",       -- bright red (salmon pink)
    "#b9f2a1",       -- bright green (lime)
    "#fce094",       -- bright yellow (sunny)
    "#a9c1ff",       -- bright blue (sky)
    "#e8bfff",       -- bright magenta (lavender)
    "#89f5e2",       -- bright cyan (aqua glow)
    mocha.text,      -- bright white
  },

  tab_bar = {
    background = mocha.crust,
    active_tab = {
      bg_color = mocha.surface0,
      fg_color = mocha.text,
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = mocha.mantle,
      fg_color = mocha.overlay1,
    },
    inactive_tab_hover = {
      bg_color = mocha.surface0,
      fg_color = mocha.text,
      italic = true,
    },
    new_tab = {
      bg_color = mocha.mantle,
      fg_color = mocha.blue,
    },
    new_tab_hover = {
      bg_color = mocha.surface0,
      fg_color = mocha.lavender,
    },
  },

  cursor_bg = mocha.lavender,
  cursor_fg = mocha.crust,
  cursor_border = mocha.lavender,
  selection_fg = mocha.text,
  selection_bg = mocha.surface2,
  split = mocha.surface1,
}

-- ==========================================================
--  POWERLINE TAB TITLES
-- ==========================================================
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

local function tab_title(tab_info)
  local title = tab_info.tab_title
  if title and #title > 0 then
    return title
  end
  return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
  local background = mocha.mantle
  local foreground = mocha.overlay1
  local edge_bg = mocha.crust

  if tab.is_active then
    background = mocha.blue
    foreground = mocha.crust
  elseif hover then
    background = mocha.surface1
    foreground = mocha.text
  end

  local title = tab_title(tab)
  local index = tab.tab_index + 1
  title = " " .. index .. ": " .. wezterm.truncate_right(title, max_width - 6) .. " "

  return {
    { Background = { Color = edge_bg } },
    { Foreground = { Color = background } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_bg } },
    { Foreground = { Color = background } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

-- ==========================================================
--  RIGHT STATUS BAR  — cwd + clock
-- ==========================================================
wezterm.on("update-right-status", function(window, pane)
  local date = wezterm.strftime(" %a %b %-d  %H:%M ")

  local cwd_uri = pane:get_current_working_dir()
  local cwd = ""
  if cwd_uri then
    cwd = cwd_uri.file_path or ""
    -- Shorten home directory
    local home = os.getenv("HOME") or ""
    if home ~= "" and cwd:sub(1, #home) == home then
      cwd = "~" .. cwd:sub(#home + 1)
    end
  end

  window:set_right_status(wezterm.format({
    { Foreground = { Color = mocha.surface2 } },
    { Text = wezterm.nerdfonts.pl_left_hard_divider },
    { Background = { Color = mocha.surface2 } },
    { Foreground = { Color = mocha.text } },
    { Text = "  " .. cwd .. "  " },
    { Foreground = { Color = mocha.blue } },
    { Text = wezterm.nerdfonts.pl_left_hard_divider },
    { Background = { Color = mocha.blue } },
    { Foreground = { Color = mocha.crust } },
    { Text = wezterm.nerdfonts.md_clock_outline .. date },
  }))
end)

-- ==========================================================
--  CURSOR
-- ==========================================================
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "EaseIn"
config.cursor_blink_ease_out = "EaseOut"

-- ==========================================================
--  INACTIVE PANE  — dim slightly
-- ==========================================================
config.inactive_pane_hsb = {
  saturation = 0.85,
  brightness = 0.65,
}

-- ==========================================================
--  SCROLLBACK
-- ==========================================================
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- ==========================================================
--  MISC
-- ==========================================================
config.audible_bell = "Disabled"
config.max_fps = 120
config.animation_fps = 60
config.front_end = "WebGpu"

-- ==========================================================
--  KEYBINDINGS
-- ==========================================================
config.keys = {
  -- Split panes (iTerm2 style)
  { key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "CMD|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- Navigate panes
  { key = "LeftArrow",  mods = "CMD|OPT", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "CMD|OPT", action = wezterm.action.ActivatePaneDirection("Right") },
  { key = "UpArrow",    mods = "CMD|OPT", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "DownArrow",  mods = "CMD|OPT", action = wezterm.action.ActivatePaneDirection("Down") },

  -- Resize panes
  { key = "LeftArrow",  mods = "CMD|SHIFT|OPT", action = wezterm.action.AdjustPaneSize({ "Left", 3 }) },
  { key = "RightArrow", mods = "CMD|SHIFT|OPT", action = wezterm.action.AdjustPaneSize({ "Right", 3 }) },
  { key = "UpArrow",    mods = "CMD|SHIFT|OPT", action = wezterm.action.AdjustPaneSize({ "Up", 3 }) },
  { key = "DownArrow",  mods = "CMD|SHIFT|OPT", action = wezterm.action.AdjustPaneSize({ "Down", 3 }) },

  -- Close pane
  { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = true }) },

  -- Quick tab switch (Cmd+1..9)
  { key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = "CMD", action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = "CMD", action = wezterm.action.ActivateTab(4) },
  { key = "6", mods = "CMD", action = wezterm.action.ActivateTab(5) },
  { key = "7", mods = "CMD", action = wezterm.action.ActivateTab(6) },
  { key = "8", mods = "CMD", action = wezterm.action.ActivateTab(7) },
  { key = "9", mods = "CMD", action = wezterm.action.ActivateTab(8) },

  -- Toggle fullscreen
  { key = "Enter", mods = "CMD|SHIFT", action = wezterm.action.ToggleFullScreen },

  -- Font size
  { key = "=", mods = "CMD", action = wezterm.action.IncreaseFontSize },
  { key = "-", mods = "CMD", action = wezterm.action.DecreaseFontSize },
  { key = "0", mods = "CMD", action = wezterm.action.ResetFontSize },
}

return config
