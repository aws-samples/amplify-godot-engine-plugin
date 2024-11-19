extends HBoxContainer
class_name AuthPassword

class THEME:
	const AUTH_PASSWORD = "AuthPassword"
	const HIDE_ICON = "hide_icon"
	const SHOW_ICON = "show_icon"
	
@onready @export var password: LineEdit = %Password
@onready @export var password_button: Button = $PasswordButton

func _ready() -> void:
	password_button.icon = get_theme_icon(THEME.SHOW_ICON, THEME.AUTH_PASSWORD)

func _on_password_button_toggled(toggled) -> void:
	password.secret = !toggled
	if toggled:
		password_button.icon = get_theme_icon(THEME.HIDE_ICON, THEME.AUTH_PASSWORD)
	else:
		password_button.icon = get_theme_icon(THEME.SHOW_ICON, THEME.AUTH_PASSWORD)
