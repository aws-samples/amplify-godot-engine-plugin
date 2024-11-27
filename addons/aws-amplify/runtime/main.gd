## Main AWS Amplify class for Godot integration.
##
## This class serves as the primary interface for AWS Amplify functionality in Godot projects.
## It handles configuration loading, client initialization, and manages auth and data modules.
class_name AWSAmplify
extends Node

## Configuration constants.
class CONFIG:
	## Authentication configuration key.
	const AUTH = "auth"
	## Data configuration key.
	const DATA = "data"

## Error message handling class.
class ERROR:
	## Generates an error message for a missing module.
	##
	## [param name]: The name of the missing module.
	## [return]: A formatted error message string.
	static func MODULE_NULL(name):
		return "No %s module! The %s configuration file doesn't contain an auth section." % name
	
	## Error message for missing auth module.
	var AUTH_NULL = MODULE_NULL(CONFIG.AUTH)
	## Error message for missing data module.
	var DATA_NULL = MODULE_NULL(CONFIG.DATA)

## Default path for the Amplify configuration file.
const DEFAULT_CONFIG_PATH := "res://amplify_outputs.json"

## Path to the current configuration file.
var config_path: String

## Loaded configuration data.
var config: Dictionary

## AWS Amplify client instance.
var client: AWSAmplifyClient

## AWS Amplify authentication module.
var auth: AWSAmplifyAuth

## AWS Amplify data module.
var data: AWSAmplifyData

## Initializes the AWSAmplify instance.
##
## [param _config_path]: Optional custom path for the configuration file.
func _init(_config_path = DEFAULT_CONFIG_PATH):
	config_path = _config_path
	config = _get_config(_config_path)
	
	client = AWSAmplifyClient.new()
	
	if config.has(CONFIG.AUTH):
		auth = AWSAmplifyAuth.new(client, config[CONFIG.AUTH])
		
		if config.has(CONFIG.DATA):
			data = AWSAmplifyData.new(client, auth, config[CONFIG.DATA])

## Sets up child nodes when the node enters the scene tree.
func _ready():
	add_child(client)
	
	if auth:
		add_child(auth)
	
		if data:
			add_child(data)
		
## Loads and parses the configuration file.
##
## [param config_path]: Path to the configuration file.
## [return]: A dictionary containing the parsed configuration data.
func _get_config(config_path) -> Dictionary:
	var file = FileAccess.open(config_path, FileAccess.READ)
	assert(file != null, "File does not exist: " + config_path)
		
	var content = file.get_as_text()
	file.close()
		
	var json = JSON.new()
	var parse_result = json.parse(content)
	
	assert(parse_result == OK, "Unable to parse file: " + config_path)
		
	return json.get_data()
