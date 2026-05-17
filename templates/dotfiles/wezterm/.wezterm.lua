local wezterm = require("wezterm")

return {
  adjust_window_size_when_changing_font_size = false,
  automatically_reload_config = true,
  enable_tab_bar = true,
  font = wezterm.font_with_fallback({
    "Hack Nerd Font",
    "FiraCode Nerd Font Mono",
  }),
  font_size = 11.0,
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,
  window_background_opacity = 0.71,
  window_padding = {
    bottom = 8,
    left = 8,
    right = 8,
    top = 8,
  },
}