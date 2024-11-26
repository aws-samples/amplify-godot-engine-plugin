class_name AuthPassword
extends HBoxContainer

## A custom password input control with a show/hide toggle button.
##
## This control combines a LineEdit for password input with a Button
## to toggle password visibility. It uses theme icons for the toggle button.

## Encapsulates theme-related constants used by AuthPassword.
class THEME:
	## The theme class name for AuthPassword.
	const AUTH_PASSWORD = "AuthPassword"
	## The theme icon name for hiding the password.
	const HIDE_ICON = "hide_icon"
	## The theme icon name for showing the password.
	const SHOW_ICON = "show_icon"

## The LineEdit node for password input.
@onready @export var password: LineEdit = %Password

## The Button node for toggling password visibility.
@onready @export var password_button: Button = %PasswordButton

## Called when the node enters the scene tree for the first time.
##
## Sets up the initial state of the password button icon.
func _ready() -> void:
	password_button.icon = get_theme_icon(THEME.SHOW_ICON, THEME.AUTH_PASSWORD)

## Handles the toggling of the password visibility button.
##
## This method is connected to the password_button's "toggled" signal.
## It changes the password field's secret mode and updates the button icon.
##
## @param toggled Whether the button is in the toggled (pressed) state.
func _on_password_button_toggled(toggled: bool) -> void:
	password.secret = !toggled
	if toggled:
		password_button.icon = get_theme_icon(THEME.HIDE_ICON, THEME.AUTH_PASSWORD)
	else:
		password_button.icon = get_theme_icon(THEME.SHOW_ICON, THEME.AUTH_PASSWORD)
