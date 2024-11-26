class_name AuthMessage
extends Label

## A custom Label for displaying authentication-related messages with color-coding.
##
## This class extends the Label node to provide specialized functionality for
## displaying messages in different colors based on their type (success, warning, error).
## It uses theme properties to determine the colors for different message types.

## Sets a regular message without color override.
##
## This method removes any existing color override and sets the label text.
##
## @param message The message to be displayed.
func set_message(message) -> void:
	remove_theme_color_override(THEME.FONT_COLOR)
	text = message

## Sets a success message with a green color.
##
## This method overrides the font color with the success color defined in the theme
## and sets the label text.
##
## @param message The success message to be displayed.
func set_success_message(message) -> void:
	add_theme_color_override(THEME.FONT_COLOR, get_theme_color(THEME.SUCCESS_COLOR, THEME.AUTH_MESSAGE))
	text = message

## Sets a warning message with a yellow color.
##
## This method overrides the font color with the warning color defined in the theme
## and sets the label text.
##
## @param message The warning message to be displayed.
func set_warn_message(message) -> void:
	add_theme_color_override(THEME.FONT_COLOR, get_theme_color(THEME.WARN_COLOR, THEME.AUTH_MESSAGE))
	text = message

## Sets an error message with a red color.
##
## This method overrides the font color with the error color defined in the theme
## and sets the label text.
##
## @param message The error message to be displayed.
func set_error_message(message) -> void:
	add_theme_color_override(THEME.FONT_COLOR, get_theme_color(THEME.ERROR_COLOR, THEME.AUTH_MESSAGE))
	text = message

## Encapsulates theme-related constants used by AuthMessage.
class THEME:
	## The theme class name for AuthMessage.
	const AUTH_MESSAGE = "AuthMessage"
	## The theme property name for the default font color.
	const FONT_COLOR = "font_color"
	## The theme property name for the success message color.
	const SUCCESS_COLOR = "success_color"
	## The theme property name for the warning message color.
	const WARN_COLOR = "warn_color"
	## The theme property name for the error message color.
	const ERROR_COLOR = "error_color"
