class_name AWSAmplify
extends Node

## AWS Amplify SDK
##
## Initializes AWS Amplify modules from the generated 'amplify_outputs.json' file.
## This SDK provides helper methods to interact with AWS Ampify provisionned backend features.
##
## Signals:
##
##   - auth.user_signed_in
##   - auth.user_changed
##   - auth.user_signed_out
##   - auth.user_signed_up
## 
## Methods:
##
##   Client:
##   - client.make_http_get(endpoint, headers, body)
##   - client.make_http_post(endpoint, headers, body)
##   - client.make_http_put(endpoint, headers, body)
##   - client.make_http_delete(endpoint, headers, body)
##   - client.make_http_request(endpoint, headers, method, body)
##
##	 Auth:
##   - auth.is_user_signed_in()
##   - auth.get_user_attribute(name, refresh_attributes)
##   - auth.get_user_attributes(refresh_attributes = false)
##   - auth.get_user_access_token_expiration_time()
##   - auth.add_user_attributes(_user_attributes: Dictionary = {})
##   - auth.remove_user_attributes(keys: Array)
##   - auth.update_user_attributes(_user_attributes: Dictionary = {})
##   - auth.refresh_user(refresh_access_token = false, refresh_attributes = false)
##   - auth.sign_in_with_username_password(username, password, auth_mode: AuthMode = AuthMode.EMAIL)
##   - auth.forgot_password(email)
##   - auth.forgot_password_confirm_code(email, confirmation_code, new_password)
##   - auth.global_sign_out()
##   - auth.sign_up(email, password, options = {})
##   - auth.sign_up_confirm_code(email, confirmation_code)
##   - auth.sign_up_resend_code(email)
##   - auth.make_authenticated_http_get(endpoint, headers, body)
##   - auth.make_authenticated_http_post(endpoint, headers, body)
##   - auth.make_authenticated_http_put(endpoint, headers, body)
##   - auth.make_authenticated_http_delete(endpoint, headers, body)
##   - auth.make_authenticated_http_request(endpoint, headers, method, body)
##
##	 Data:
##   - data.make_graphql_query(query, operation_name, authenticated)
##   - data.make_graphql_mutation(mutation, operation_name, authenticated)
##   - data.make_graphql_request(query, operation_name, method, authenticated)
##

class CONFIG:
	const AUTH = "auth"
	const DATA = "data"

class ERROR:
	static func MODULE_NULL(name):
		return "No %s module! The %s configuration file doesn't contain an auth section." % name
	var AUTH_NULL = MODULE_NULL(CONFIG.AUTH)
	var DATA_NULL = MODULE_NULL(CONFIG.DATA)

const DEFAULT_CONFIG_PATH := "res://amplify_outputs.json"

var config_path: String
var config: Dictionary
var client: AWSAmplifyClient
var auth: AWSAmplifyAuth
var data: AWSAmplifyData

func _init(_config_path = DEFAULT_CONFIG_PATH):
	config_path = _config_path
	config = _get_config(_config_path)
	
	client = AWSAmplifyClient.new()
	
	if config.has(CONFIG.AUTH):
		auth = AWSAmplifyAuth.new(client, config[CONFIG.AUTH])
		
		if config.has(CONFIG.DATA):
			data = AWSAmplifyData.new(client, auth, config[CONFIG.DATA])

func _ready():
	add_child(client)
	
	if auth:
		add_child(auth)
	
		if data:
			add_child(data)
		
func _get_config(config_path) -> Dictionary:
	var file = FileAccess.open(config_path, FileAccess.READ)
	assert(file != null, "File does not exist: " + config_path)
		
	var content = file.get_as_text()
	file.close()
		
	var json = JSON.new()
	var parse_result = json.parse(content)
	
	assert(parse_result == OK, "Unable to parse file: " + config_path)
		
	return json.get_data()
