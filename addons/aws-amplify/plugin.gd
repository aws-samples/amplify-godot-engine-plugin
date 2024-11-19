@tool
extends EditorPlugin
class_name AWSAmplifyPlugin

const AWS_AMPLIFY_PLUGIN_NAME = "AWS Amplify"
const AWS_AMPLIFY_PLUGIN_ICON: Texture2D = preload("res://addons/aws-amplify/plugin/icons/logo.svg")
const AWS_AMPLIFY_PLUGIN_HOME: String = "https://github.com/aws-samples/amplify-godot-engine-plugin"

const AWS_AMPLIFY_NAME = "aws_amplify"
const AWS_AMPLIFY_PATH = "res://addons/aws-amplify/runtime/main.gd"

func _enter_tree() -> void:
	
	# add AWS Amplify singleton autload
	add_autoload_singleton(AWS_AMPLIFY_NAME, AWS_AMPLIFY_PATH)
	
	# display welcome message
	print("%s Plugin v%s (c) 2024-present Amazon, Inc" % [AWS_AMPLIFY_PLUGIN_NAME, get_plugin_version()])
	print("Use '%s' singleton to access AWS Amplify backend resources" % [AWS_AMPLIFY_NAME])
	print("Please visit %s!" % [AWS_AMPLIFY_PLUGIN_HOME])
		
func _exit_tree() -> void:
	
	# remove AWS Amplify singleton autload
	remove_autoload_singleton(AWS_AMPLIFY_NAME)

func _has_main_screen() -> bool:
	return false

func _get_plugin_name() -> String:
	return AWS_AMPLIFY_PLUGIN_NAME

func _get_plugin_icon() -> Texture2D:
	return AWS_AMPLIFY_PLUGIN_ICON
