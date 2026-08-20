extends RefCounted
class_name SwordigoTheme

## Authoritative Swordigo Design System Palette & Style Definitions
## Sourced from authentic Touch Foo Swordigo game references.

const COLOR_GOLD_PRIMARY: Color = Color(0.98, 0.79, 0.28, 1.0) # #facb47 (Swordigo Gold)
const COLOR_HEALTH_RED: Color = Color(0.91, 0.16, 0.16, 1.0)   # #e82828 (Heart Container Red)
const COLOR_HEART_RED: Color = COLOR_HEALTH_RED
const COLOR_MANA_BLUE: Color = Color(0.16, 0.53, 0.91, 1.0)    # #2888e8 (Mana Tube Blue)
const COLOR_SHARD_CYAN: Color = Color(0.25, 0.88, 0.82, 1.0)   # #40e0d0 (Soul Shard Cyan)
const COLOR_SLATE_DARK: Color = Color(0.11, 0.14, 0.18, 1.0)   # #1d232e (Menu Slate)
const COLOR_WOOD_DARK: Color = Color(0.18, 0.11, 0.06, 1.0)    # #2e1b10 (Deep Wood)
const COLOR_PARCHMENT: Color = Color(0.91, 0.85, 0.72, 1.0)    # #e8d8b8 (Scroll Parchment)
const COLOR_TEXT_MUTED: Color = Color(0.72, 0.75, 0.8, 1.0)

static func create_slate_stylebox() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = COLOR_SLATE_DARK
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = COLOR_GOLD_PRIMARY
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_right = 6
	sb.corner_radius_bottom_left = 6
	return sb

static func create_parchment_stylebox() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = COLOR_WOOD_DARK
	sb.border_width_left = 3
	sb.border_width_top = 3
	sb.border_width_right = 3
	sb.border_width_bottom = 3
	sb.border_color = COLOR_GOLD_PRIMARY
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_right = 10
	sb.corner_radius_bottom_left = 10
	return sb
