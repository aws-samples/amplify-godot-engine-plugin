extends Label
class_name AuthMessage

class THEME:
	const AUTH_MESSAGE = "AuthMessage"
	const FONT_COLOR = "font_color"
	const SUCCESS_COLOR = "success_color"
	const WARN_COLOR = "warn_color"
	const ERROR_COLOR = "error_color"

func set_message(message) -> void:
	remove_theme_color_override(THEME.FONT_COLOR)
	text = message

func set_success_message(message) -> void:
	add_theme_color_override(THEME.FONT_COLOR, get_theme_color(THEME.SUCCESS_COLOR, THEME.AUTH_MESSAGE))
	text = message

func set_warn_message(message) -> void:
	add_theme_color_override(THEME.FONT_COLOR, get_theme_color(THEME.WARN_COLOR, THEME.AUTH_MESSAGE))
	text = message

func set_error_message(message) -> void:
	add_theme_color_override(THEME.FONT_COLOR, get_theme_color(THEME.ERROR_COLOR, THEME.AUTH_MESSAGE))
	text = message
