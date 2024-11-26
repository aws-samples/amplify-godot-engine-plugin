@tool
class_name AWSAmplifyPlugin
extends EditorPlugin
## AWS Amplify plugin for Godot Engine.
##
## This plugin integrates AWS Amplify functionality into Godot projects,
## allowing easy access to AWS backend resources.
##
## @tutorial: https://github.com/aws-samples/amplify-godot-engine-plugin
## @tutorial: https://github.com/aws-samples/amplify-godot-engine/wiki

## Name of the AWS Amplify plugin.
const AWS_AMPLIFY_PLUGIN_NAME = "AWS Amplify"

## Icon for the AWS Amplify plugin.
const AWS_AMPLIFY_PLUGIN_ICON: Texture2D = preload("res://addons/aws-amplify/plugin/icons/logo.svg")

## Home page URL for the AWS Amplify plugin.
const AWS_AMPLIFY_PLUGIN_HOME: String = "https://github.com/aws-samples/amplify-godot-engine-plugin"

## Name of the AWS Amplify singleton.
const AWS_AMPLIFY_NAME = "aws_amplify"

## Path to the AWS Amplify main script.
const AWS_AMPLIFY_PATH = "res://addons/aws-amplify/runtime/main.gd"

## Called when the plugin enters the scene tree.
func _enter_tree() -> void:
	# Add AWS Amplify singleton autoload
	add_autoload_singleton(AWS_AMPLIFY_NAME, AWS_AMPLIFY_PATH)
	
	# Display welcome message
	print("%s Plugin v%s (c) 2024-present Amazon, Inc" % [AWS_AMPLIFY_PLUGIN_NAME, get_plugin_version()])
	print("Use '%s' singleton to access AWS Amplify backend resources" % [AWS_AMPLIFY_NAME])
	print("Please visit %s!" % [AWS_AMPLIFY_PLUGIN_HOME])
		
## Called when the plugin exits the scene tree.
func _exit_tree() -> void:
	# Remove AWS Amplify singleton autoload
	remove_autoload_singleton(AWS_AMPLIFY_NAME)

## Determines if the plugin has a main screen.
func _has_main_screen() -> bool:
	return false

## Returns the name of the plugin.
func _get_plugin_name() -> String:
	return AWS_AMPLIFY_PLUGIN_NAME

## Returns the icon for the plugin.
func _get_plugin_icon() -> Texture2D:
	return AWS_AMPLIFY_PLUGIN_ICON
