## AWS Amplify Authentication client for Godot.
##
## Provides methods for user authentication, sign up, sign in, password management,
## and user attribute management using Amazon Cognito.
class_name AWSAmplifyAuth
extends Node

## Emitted when a user successfully signs in.
signal user_signed_in

## Emitted when user attributes are changed.
signal user_changed

## Emitted when a user si signs out.
signal user_signed_out

## Emitted when a new user successfully signs up.
signal user_signed_up

## Signs up a new user.
##
## @param username The username to sign up with.
## @param password The password for the new account.
## @param options Additional options for sign up.
## @return A dictionary containing the response from the sign up operation.
func sign_up(username, password, options: Dictionary = {}):
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,
		RequestHeaders.X_AMZ_TARGET("SignUp"),
	]

	var user_attributes = _options_to_dictionary(AuthOptions.USER_ATTRIBUTES, options)
	var username_attribute = get_username_attribute()
	user_attributes[username_attribute] = username
	
	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_ID],
		RequestBody.USERNAME: username,
		RequestBody.PASSWORD: password,
		RequestBody.USER_ATTRIBUTES: _dictionary_to_array(user_attributes)
	}

	var response = await _client.post_json(_endpoint, headers, body)
	
	if response.status == ResponseStatus.SUCCESS:
		user_signed_up.emit()
		
	return response

## Confirms a user's sign up using a confirmation code.
##
## @param username The username of the user to confirm.
## @param confirmation_code The confirmation code sent to the user.
## @param options Additional options for confirmation.
## @return A dictionary containing the response from the confirmation operation.
func confirm_sign_up(username: String, confirmation_code: String, options: Dictionary = {}):
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,
		RequestHeaders.X_AMZ_TARGET("ConfirmSignUp")
	]

	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_ID],
		RequestBody.USERNAME: username,
		RequestBody.CONFIRMATION_CODE: confirmation_code,
		RequestBody.USER_ATTRIBUTES: _options_to_array(AuthOptions.USER_ATTRIBUTES, options)
	}

	return await _client.post_json(_endpoint, headers, body)

## Resends the sign up confirmation code to a user.
##
## @param username The username of the user to resend the code to.
## @param options Additional options for resending the code.
## @return A dictionary containing the response from the resend operation.
func resend_sign_up_code(username, options: Dictionary = {}):
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,
		RequestHeaders.X_AMZ_TARGET("ResendConfirmationCode")
	]

	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_ID],
		RequestBody.USERNAME: username,
		RequestBody.USER_ATTRIBUTES: _options_to_array(AuthOptions.USER_ATTRIBUTES, options)
	}
	
	return await _client.post_json(_endpoint, headers, body)

## Checks if a user is currently signed in.
##
## @return True if a user is signed in and the access token is valid, false otherwise.
func is_signed_in():
	return (
		_tokens.has(Token.ACCESS_TOKEN) && 
		_token_expiration_time(_tokens[Token.ACCESS_TOKEN]) > Time.get_unix_time_from_system()
	)

## Signs in a user with their username and password.
##
## @param username The username of the user to sign in.
## @param password The password of the user.
## @param options Additional options for sign in.
## @return A dictionary containing the response from the sign in operation.
func sign_in(username, password, options: Dictionary = {}):
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,
		RequestHeaders.X_AMZ_TARGET("InitiateAuth")
	]
	
	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_ID],
		RequestBody.AUTH_FLOW: "USER_PASSWORD_AUTH",
		RequestBody.AUTH_PARAMETERS: {
			"USERNAME": username,
			"PASSWORD": password
		},
		RequestBody.USER_ATTRIBUTES: _options_to_array(AuthOptions.USER_ATTRIBUTES, options)
	}

	var response = await _client.post_json(_endpoint, headers, body)
		
	if response.status == ResponseStatus.SUCCESS:
		if response.result.has(ResponseBody.AUTHENTICATION_RESULT) and response.result[ResponseBody.AUTHENTICATION_RESULT].has(ResponseBody.ACCESS_TOKEN):
			
			var authenticated_result = response.result[ResponseBody.AUTHENTICATION_RESULT]
			_tokens.set_all(authenticated_result)

			var user_attributes = await fetch_user_attributes()
			if _user_attributes:
				_user_attributes.set_all(user_attributes)
				user_signed_in.emit(_user_attributes)
			else:
				_clear_user_attributes()
		
	return response

## Initiates the password reset process for a user.
##
## @param username The username of the user to reset the password for.
## @param options Additional options for password reset.
## @return A dictionary containing the response from the password reset operation.
func reset_password(username, options: Dictionary = {}):
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,
		RequestHeaders.X_AMZ_TARGET("ForgotPassword")
	]

	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_ID],
		RequestBody.USERNAME: username,
		RequestBody.USER_ATTRIBUTES: _options_to_array(AuthOptions.USER_ATTRIBUTES, options)
	}

	return await _client.post_json(_endpoint, headers, body)

## Confirms a password reset with a new password and confirmation code.
##
## @param username The username of the user resetting their password.
## @param new_password The new password for the user.
## @param confirmation_code The confirmation code sent to the user.
## @param options Additional options for password reset confirmation.
## @return A dictionary containing the response from the password reset confirmation operation.
func confirm_reset_password(username, new_password, confirmation_code, options: Dictionary = {}):
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,
		RequestHeaders.X_AMZ_TARGET("ConfirmForgotPassword")
	]

	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_ID],
		RequestBody.USERNAME: username,
		RequestBody.PASSWORD: new_password,
		RequestBody.CONFIRMATION_CODE: confirmation_code
	}

	return await _client.post_json(_endpoint, headers, body)

## Updates the password for the currently signed-in user.
##
## @param old_password The current password of the user.
## @param new_password The new password to set.
## @param options Additional options for password update.
## @return A dictionary containing the response from the password update operation.
func update_password(old_password, new_password, options: Dictionary = {}):
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,
		RequestHeaders.X_AMZ_TARGET("UpdatePassword")
	]

	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_ID],
		RequestBody.ACCESS_TOKEN: _tokens[Token.ACCESS_TOKEN],
		RequestBody.PREVIOUS_PASSWORD: old_password,
		RequestBody.PROPOSED_PASSWORD: new_password
	}

	return await post_json(_endpoint, headers, body)

## Updates multiple user attributes for the currently signed-in user.
##
## @param user_attributes A dictionary of user attributes to update.
## @param options Additional options for attribute update.
## @return A dictionary containing the response from the attribute update operation.
func update_user_attributes(user_attributes: Dictionary, options: Dictionary = {}):
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,
		RequestHeaders.X_AMZ_TARGET("UpdateUserAttributes")
	]
	
	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_ID],
		RequestBody.ACCESS_TOKEN: _tokens[Token.ACCESS_TOKEN],
		RequestBody.USER_ATTRIBUTES: _dictionary_to_array(user_attributes)
	}

	var response = await _client.post_json(_endpoint, headers, body)
	
	if response.status == ResponseStatus.SUCCESS:
		_user_attributes.merge(user_attributes, true)
		user_changed.emit(_user_attributes)
		
	return response

## Updates a single user attribute for the currently signed-in user.
##
## @param user_attribute_name The name of the attribute to update.
## @param user_attribute_value The new value for the attribute.
## @param options Additional options for attribute update.
## @return A dictionary containing the response from the attribute update operation.
func update_user_attribute(user_attribute_name: String, user_attribute_value, options: Dictionary = {}):
	return await update_user_attributes({ user_attribute_name: user_attribute_value }, options)

## Confirms a user attribute update using a confirmation code.
##
## @param attribute_name The name of the attribute to confirm.
## @param confirmation_code The confirmation code sent to the user.
## @param options Additional options for attribute confirmation.
## @return A dictionary containing the response from the attribute confirmation operation.
func confirm_user_attribute(attribute_name: String, confirmation_code: String, options: Dictionary = {}):
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,
		RequestHeaders.X_AMZ_TARGET("VerifyUserAttribute"),
	]
	
	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_ID],
		RequestBody.ACCESS_TOKEN: _tokens[Token.ACCESS_TOKEN],
		RequestBody.ATTRIBUTE_NAME: attribute_name,
		RequestBody.CONFIRMATION_CODE: confirmation_code
	}

	return await _client.post_json(_endpoint, headers, body)

## Sends a confirmation code for a user attribute update.
##
## @param attribute_name The name of the attribute to send a confirmation code for.
## @param confirmation_code The confirmation code to send.
## @param options Additional options for sending the confirmation code.
## @return A dictionary containing the response from the send confirmation code operation.
func send_user_attribute_confirmation_code(attribute_name: String, confirmation_code: String, options: Dictionary = {}):
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,
		RequestHeaders.X_AMZ_TARGET("GetUserAttributeVerificationCode"),
	]
	
	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_ID],
		RequestBody.ACCESS_TOKEN: _tokens[Token.ACCESS_TOKEN],
		RequestBody.ATTRIBUTE_NAME: attribute_name
	}

	return await _client.post_json(_endpoint, headers, body)

## Deletes multiple user attributes for the currently signed-in user.
##
## @param user_attribute_names An array of attribute names to delete.
## @return A dictionary containing the response from the attribute deletion operation.
func delete_user_attributes(user_attribute_names: Array[String]):
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,
		RequestHeaders.X_AMZ_TARGET("UpdateUserAttributes")
	]
	
	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_ID],
		RequestBody.ACCESS_TOKEN: _tokens[Token.ACCESS_TOKEN],
		RequestBody.USER_ATTRIBUTE_NAMES: user_attribute_names
	}

	var response = await _client.post_json(_endpoint, headers, body)
	
	if response.status == ResponseStatus.SUCCESS:
		for user_attribute_name in user_attribute_names:
			_user_attributes[user_attribute_name] = null
		user_changed.emit(_user_attributes)
		
	return response

## Fetches the current user's attributes.
##
## @return A dictionary of user attributes.
func fetch_user_attributes() :
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,
		RequestHeaders.X_AMZ_TARGET("GetUser"),
	]
	
	var body = {
		RequestBody.ACCESS_TOKEN: _tokens[Token.ACCESS_TOKEN]
	}

	var response = await _client.post_json(_endpoint, headers, body)
	
	if response.status == ResponseStatus.SUCCESS:
		var attributes = response.result[ResponseBody.USER_ATTRIBUTES]
		return _array_to_dictionary(attributes)
	else:    
		return {}

## Signs out the current user.
##
## @param global If true, signs out the user from all devices.
## @return A dictionary containing the response from the sign out operation.
func sign_out(global: bool = false):
	if global:
		return await global_sign_out()
	else:
		return await revoke_token()

## Signs out the current user from all devices.
##
## @return A dictionary containing the response from the global sign out operation.
func global_sign_out():
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,        
		RequestHeaders.X_AMZ_TARGET("GlobalSignOut")
	]

	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_ID],
		RequestBody.ACCESS_TOKEN: _tokens[Token.ACCESS_TOKEN]
	}
	
	var response = await _client.post_json(_endpoint, headers, body)
	
	if response.status == ResponseStatus.SUCCESS:
		user_signed_out.emit(_user_attributes)
		_clear_tokens()
		
	return response

## Revokes the current refresh token, effectively signing out the user.
##
## @return A dictionary containing the response from the token revocation operation.
func revoke_token():
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,        
		RequestHeaders.X_AMZ_TARGET("RevokeToken")
	]

	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_ID],
		RequestBody.TOKEN: _tokens[Token.REFRESH_TOKEN]
	}
	
	if _config.has(Config.CLIENT_SECRET):
		body[RequestBody.CLIENT_SECRET] = _config[Config.CLIENT_SECRET]

	var response = await _client.post_json(_endpoint, headers, body)
	
	if response.status == ResponseStatus.SUCCESS:
		user_signed_out.emit(_user_attributes)
		_clear_tokens()
	else:
		print(response.error)
		
	return response

## Refreshes the current access token using a refresh token.
##
## @param refresh_token The refresh token to use for getting a new access token.
## @return A dictionary containing the response from the token refresh operation.
func refresh_token(refresh_token):
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,
		RequestHeaders.X_AMZ_TARGET("InitiateAuth")
	]
	
	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_SECRET],
		RequestBody.AUTH_FLOW:"REFRESH_TOKEN_AUTH",
		RequestBody.AUTH_PARAMETERS: {
			"REFRESH_TOKEN": refresh_token
		}
	}
	
	var response = await _client.post_json(_endpoint, headers, body)
	
	if response.status == ResponseStatus.SUCCESS:
		if response.result.has(ResponseBody.AUTHENTICATION_RESULT) and response.result[ResponseBody.AUTHENTICATION_RESULT].has(ResponseBody.ACCESS_TOKEN):
			var authentication_result = response.result[ResponseBody.AUTHENTICATION_RESULT]
			_tokens.set_all(authentication_result)
			
	return response

## Gets a specific token by name.
##
## @param name The name of the token to retrieve.
## @return The requested token, or null if not found.
func get_token(name):
	if _tokens.has(name):
		return _tokens[name]
	else:
		return null

## Gets the expiration time of the current access token.
##
## @return The expiration time as a Unix timestamp, or 0 if no access token is present.
func get_token_expiration_time() -> int:
	if _tokens.has(Token.ACCESS_TOKEN):
		return _token_expiration_time(_tokens[Token.ACCESS_TOKEN])
	else:
		return 0

## Deletes the current user's account.
##
## @return A dictionary containing the response from the account deletion operation.
func delete_user():
	var headers = [
		RequestHeaders.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1,
		RequestHeaders.X_AMZ_TARGET("DeleteUser")
	]
	
	var body = {
		RequestBody.CLIENT_ID: _config[Config.CLIENT_SECRET],
		RequestBody.ACCESS_TOKEN: _tokens[Token.ACCESS_TOKEN]
	}
	
	return await _client.post_json(_endpoint, headers, body)

## Gets a specific user attribute.
##
## @param name The name of the attribute to retrieve.
## @param refresh_attributes Whether to refresh the user attributes before retrieving.
## @return The value of the requested attribute, or null if not found.
func get_user_attribute(name: String, refresh_attributes = false):
	var attributes = get_user_attributes(refresh_attributes)
	if attributes.has(name):
		return attributes[name]
	else:
		return null

## Gets all user attributes.
##
## @param refresh_attributes Whether to refresh the user attributes before retrieving.
## @return A dictionary of all user attributes.
func get_user_attributes(refresh_attributes = false):
	refresh_user(refresh_attributes)
	return _user_attributes

## Adds multiple user attributes.
##
## @param user_attributes A dictionary of attributes to add.
func add_user_attributes(user_attributes: Dictionary):
	var response = await update_user_attributes(user_attributes)
	if response.status == ResponseStatus.SUCCESS:
		_user_attributes.merge(user_attributes)
		user_changed.emit(_user_attributes)

## Removes multiple user attributes.
##
## @param keys An array of attribute names to remove.
func remove_user_attributes(keys: Array):
	var response = await delete_user_attributes(keys)
	if response.status == ResponseStatus.SUCCESS:
		for key in keys:
			_user_attributes.erase(key)
		user_changed.emit(_user_attributes)

## Refreshes the current user's tokens and attributes.
##
## @param refresh_token Whether to refresh the access token.
## @param refresh_user_attributes Whether to refresh the user attributes.
func refresh_user(refresh_token = false, refresh_user_attributes = false):
	if _tokens.has(Token.ACCESS_TOKEN):
		var token_expiration_time = _token_expiration_time(_tokens[Token.ACCESS_TOKEN])
		
		# refresh user access token if user access token has expired
		if (refresh_token or 
			(token_expiration_time < Time.get_unix_time_from_system() 
			and _tokens[Token.REFRESH_TOKEN])):
			var response = await refresh_token(_tokens[Token.REFRESH_TOKEN])
			if not response.success:
				_clear_tokens()
		
		# refresh user attributes
		if refresh_user_attributes:
			_user_attributes = await fetch_user_attributes()
			if _user_attributes:
				user_changed.emit(_user_attributes)
			else:
				_clear_tokens()
		else:
			user_changed.emit(_user_attributes)
	else:
		_clear_user_attributes()

## Gets the username attribute used for sign-in.
##
## @return The name of the username attribute.
func get_username_attribute():
	if _config.has(Config.USERNAME_ATTRIBUTES):
		var username_attributes = _config[Config.USERNAME_ATTRIBUTES]
		return username_attributes[0]
	else:
		return UserAttributes.EMAIL

## Sends a GET request with JSON body.
##
## @param endpoint The API endpoint.
## @param headers The request headers.
## @param json_body The JSON body of the request.
## @return A dictionary containing the response from the GET request.
func get_json(endpoint: String, headers: Array, json_body: Dictionary):
	return await send_json(endpoint, headers, HTTPClient.METHOD_GET , json_body)

## Sends a POST request with JSON body.
##
## @param endpoint The API endpoint.
## @param headers The request headers.
## @param json_body The JSON body of the request.
## @return A dictionary containing the response from the POST request.
func post_json(endpoint: String, headers: Array, json_body: Dictionary):
	return await send_json(endpoint, headers, HTTPClient.METHOD_POST, json_body)

## Sends a PUT request with JSON body.
##
## @param endpoint The API endpoint.
## @param headers The request headers.
## @param json_body The JSON body of the request.
## @return A dictionary containing the response from the PUT request.
func put_json(endpoint: String, headers: Array, json_body: Dictionary):
	return await send_json(endpoint, headers, HTTPClient.METHOD_PUT, json_body)

## Sends a DELETE request with JSON body.
##
## @param endpoint The API endpoint.
## @param headers The request headers.
## @param body The JSON body of the request.
## @return A dictionary containing the response from the DELETE request.
func delete_json(endpoint: String, headers: Array, body: Dictionary):
	return await send_json(endpoint, headers, HTTPClient.METHOD_DELETE, body)

## Sends a JSON request with the specified method.
##
## @param endpoint The API endpoint.
## @param headers The request headers.
## @param method The HTTP method to use.
## @param json_body The JSON body of the request.
## @return A dictionary containing the response from the request.
func send_json(endpoint: String, headers: Array, method: HTTPClient.Method, json_body: Dictionary):
	# automatically refresh access token if expired
	refresh_user()
	# append access token to the authorization bearer
	headers.append(RequestHeaders.AUTHORIZATION_BEARER(_tokens[Token.ACCESS_TOKEN]))
	return await _client.send_json(endpoint, headers, method, json_body)

## Sends a GET request.
##
## @param endpoint The API endpoint.
## @param headers The request headers.
## @param body The body of the request.
## @return A dictionary containing the response from the GET request.
func get_(endpoint: String, headers: Array, body: String):
	return await send(endpoint, headers, HTTPClient.METHOD_GET , body)

## Sends a POST request.
##
## @param endpoint The API endpoint.
## @param headers The request headers.
## @param body The body of the request.
## @return A dictionary containing the response from the POST request.
func post(endpoint: String, headers: Array, body: String):
	return await send(endpoint, headers, HTTPClient.METHOD_POST, body)

## Sends a PUT request.
##
## @param endpoint The API endpoint.
## @param headers The request headers.
## @param body The body of the request.
## @return A dictionary containing the response from the PUT request.
func put(endpoint: String, headers: Array, body: String):
	return await send(endpoint, headers, HTTPClient.METHOD_PUT, body)

## Sends a DELETE request.
##
## @param endpoint The API endpoint.
## @param headers The request headers.
## @param body The body of the request.
## @return A dictionary containing the response from the DELETE request.
func delete(endpoint: String, headers: Array, body: String):
	return await send(endpoint, headers, HTTPClient.METHOD_DELETE, body)

## Sends a request with the specified method.
##
## @param endpoint The API endpoint.
## @param headers The request headers.
## @param method The HTTP method to use.
## @param body The body of the request.
## @return A dictionary containing the response from the request.
func send(endpoint: String, headers: Array, method: HTTPClient.Method, body: String):
	# automatically refresh access token if expired
	refresh_user()
	# append access token to the authorization bearer
	headers.append(RequestHeaders.AUTHORIZATION_BEARER(_tokens[Token.ACCESS_TOKEN]))
	return await _client.send(endpoint, headers, method, body)

## The AWS Amplify client used for making requests.
var _client: AWSAmplifyClient
## The configuration dictionary for the AWS Amplify Auth client.
var _config: Dictionary
## The endpoint URL for the Cognito service.
var _endpoint: String
## The storage for authentication tokens.
var _tokens: AuthStore
## The storage for user attributes.
var _user_attributes: AuthStore

## Initializes the AWS Amplify Auth client.
##
## @param client The AWS Amplify client to use for requests.
## @param config The configuration dictionary for the Auth client.
func _init(client: AWSAmplifyClient, config: Dictionary) -> void:
	_client = client
	_config = config
	_endpoint = "https://cognito-idp." + config[Config.REGION] + ".amazonaws.com/"
	_tokens = AuthMemoryStore.new()
	_user_attributes = AuthMemoryStore.new()

## Clears all stored tokens.
func _clear_tokens():
	_tokens.clear()
	_clear_user_attributes()

## Clears all stored user attributes.
func _clear_user_attributes():
	_user_attributes.clear()
	user_changed.emit(_user_attributes)

## Calculates the expiration time of an access token.
##
## @param access_token The access token to check.
## @return The expiration time as a Unix timestamp.
func _token_expiration_time(access_token):
	var decoded_token = _decode_jwt(access_token)
	var token_payload = decoded_token[Jwt.PAYLOAD]
	return token_payload.exp

## Decodes a JWT token.
##
## @param token The JWT token to decode.
## @return A dictionary containing the decoded header and payload.
func _decode_jwt(token):
	var parts = token.split(".")
	
	assert(parts.size() == 3, "JWT Token must have 3 parts: header, payload and verified signature.")
	
	var header_byte_array = _base64URL_decode(parts[0])
	var header = _parse_json(header_byte_array)
	var payload_string = _base64URL_decode(parts[1])
	var payload = _parse_json(payload_string)
	
	return {
		Jwt.HEADER: header, 
		Jwt.PAYLOAD: payload
	}
	
## Decodes a base64URL-encoded string.
##
## @param input The base64URL-encoded string to decode.
## @return The decoded byte array.
func _base64URL_decode(input: String) -> PackedByteArray:
	match (input.length() % 4):
		2: input += "=="
		3: input += "="
	return Marshalls.base64_to_raw(input.replacen("_","/").replacen("-","+"))

## Parses a JSON string.
##
## @param field The JSON string to parse.
## @return A dictionary containing the parsed JSON data.
func _parse_json(field: PackedByteArray) -> Dictionary:
	return JSON.parse_string(field.get_string_from_utf8())

## Extracts a dictionary from options.
##
## @param name The name of the option to extract.
## @param options The options dictionary.
## @return The extracted dictionary.
func _options_to_dictionary(name: String, options: Dictionary) -> Dictionary:
	var dictionary = {}
	if options.has(name):
		dictionary = options[name]
	return dictionary

## Extracts an array from options.
##
## @param name The name of the option to extract.
## @param options The options dictionary.
## @return The extracted array.
func _options_to_array(name: String, options: Dictionary) -> Array:
	var dictionary = {}
	if options.has(name):
		dictionary = options[name]
	return _dictionary_to_array(dictionary)

## Converts a dictionary to an array of name-value pairs.
##
## @param dictionary The dictionary to convert.
## @return An array of name-value pair dictionaries.
func _dictionary_to_array(dictionary: Dictionary) -> Array:
	var array = []
	for key in dictionary:
		array.append({
			"Name": key,
			"Value": dictionary[key]
		})
	return array

## Converts an array of name-value pairs to a dictionary.
##
## @param array The array of name-value pairs to convert.
## @return A dictionary with the name-value pairs.
func _array_to_dictionary(array: Array) -> Dictionary:
	var dictionary = {}
	for entry in array:
		dictionary[entry.Name] = entry.Value
	return dictionary

## Base class for auth storage implementations.
class AuthStore:
	func clear(): _not_implemented_yet()
	func erase(key: Variant) -> bool: return _not_implemented_yet(false)
	func find_key(value: Variant) -> Variant: return _not_implemented_yet(null)
	func _get(key: Variant, default: Variant = null) -> Variant: return _not_implemented_yet(null)
	func get_all() -> Dictionary: return _not_implemented_yet(_empty_dictionary)
	func get_or_add(key: Variant, default: Variant = null) -> Variant: return _not_implemented_yet(null) 
	func has(key: Variant) -> bool: return _not_implemented_yet(false) 
	func has_all(keys: Array) -> bool: return _not_implemented_yet(false)
	func is_empty() -> bool: return _not_implemented_yet(false)
	func keys() -> Array: return _not_implemented_yet(_empty_array) 
	func merge(dict: Dictionary, overwrite: bool = false) -> void: _not_implemented_yet()
	func _set(property: StringName, value: Variant) -> bool: return _not_implemented_yet(false) 
	func set_all(values: Dictionary) -> bool: return _not_implemented_yet(false) 
	func size() -> int: return _not_implemented_yet(-1)
	func values() -> Array: return _not_implemented_yet(_empty_array)
	
	func _not_implemented_yet(value = null):
		assert(false, "Not Implemented Yet!")
		return value
		
	const _empty_array = []
	const _empty_dictionary = {}

## In-memory implementation of AuthStore.
class AuthMemoryStore extends AuthStore:
	func clear(): _dict.clear()
	func erase(key: Variant) -> bool: return _dict.erase(key)
	func find_key(value: Variant) -> Variant: return _dict.find_key(value)
	func _get(key: Variant, default: Variant = null) -> Variant: return _dict.get(key)
	func get_all() -> Dictionary: return _dict
	func get_or_add(key: Variant, default: Variant = null) -> Variant: return _dict.get_or_add(key, default)
	func has(key: Variant) -> bool: return _dict.has(key)
	func has_all(keys: Array) -> bool: return _dict.has_all(keys)
	func is_empty() -> bool: return _dict.is_empty()
	func keys() -> Array: return _dict.keys()
	func merge(dict: Dictionary, overwrite: bool = false) -> void: _dict.merge(dict, overwrite)
	func _set(name: StringName, value: Variant) -> bool: _dict[name] = value; return true
	func set_all(values: Dictionary) -> bool: 
		_dict.clear()
		_dict.merge(values)
		return true
	func size() -> int: return _dict.size()
	func values() -> Array: return _dict.values()
		
	var _dict = {}

## Configuration constants for AWS Amplify.
class Config:
	## AWS region.
	const REGION = "aws_region"
	## Cognito user pool client ID.
	const CLIENT_ID = "user_pool_client_id"
	## Cognito user pool client secret.
	const CLIENT_SECRET = "user_pool_client_secret"
	## Attributes that can be used as username.
	const USERNAME_ATTRIBUTES = "username_attributes"
	## User verification types.
	const USER_VERIFICATION_TYPE = "user_verification_types"

## Token constants for authentication.
class Token:
	## Access token key.
	const ACCESS_TOKEN = "AccessToken"
	## Access token expiration time key.
	const EXPIRES_IN = "AccessTokenExpirationTime"
	## ID token key.
	const ID_TOKEN = "IdToken"
	## Refresh token key.
	const REFRESH_TOKEN = "RefreshToken"
	## Token type key.
	const TOKEN_TYPE = "TokenType"

## JWT (JSON Web Token) constants.
class Jwt:
	## JWT header key.
	const HEADER = "header"
	## JWT payload key.
	const PAYLOAD = "payload"
	## JWT verified signature key.
	const VERIFIED_SIGNATURE = "verified_signature"

## Authentication options constants.
class AuthOptions:
	## User attributes key.
	const USER_ATTRIBUTES = "userAttributes"
	## Client metadata key.
	const CLIENT_METADATA = "clientMetadata"

## Request header constants and functions.
class RequestHeaders:
	## Content type for AWS Cognito JSON requests.
	const CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1 = "Content-Type: application/x-amz-json-1.1"
	
	## Generates the X-Amz-Target header.
	## @param target The target service and operation.
	## @return The formatted X-Amz-Target header.
	static func X_AMZ_TARGET(target) -> String:
		return "X-Amz-Target: AWSCognitoIdentityProviderService." + target
	
	## Generates the Authorization header with a bearer token.
	## @param access_token The access token to use.
	## @return The formatted Authorization header.
	static func AUTHORIZATION_BEARER(access_token) -> String:
		return "Authorization: Bearer " + access_token

## Request body constants for AWS Cognito operations.
class RequestBody:
	const ACCESS_TOKEN = "AccessToken"
	const ATTRIBUTE_NAME = "AttributeName"
	const AUTH_FLOW = "AuthFlow"
	const AUTH_PARAMETERS = "AuthParameters"
	const CLIENT_ID = "ClientId"
	const CLIENT_SECRET = "ClientSecret"
	const CLIENT_METADATA = "ClientMetadata"
	const CONFIRMATION_CODE = "ConfirmationCode"
	const PASSWORD = "Password"
	const PREVIOUS_PASSWORD = "PreviousPassword"
	const PROPOSED_PASSWORD = "ProposedPassword"
	const REFRESH_TOKEN = "RefreshToken"
	const TOKEN = "Token"
	const USERNAME = "Username"
	const USER_ATTRIBUTES = "UserAttributes"
	const USER_ATTRIBUTE_NAMES = "UserAttributeNames"

## Response status constants (imported from AWSAmplifyClient).
const ResponseStatus = AWSAmplifyClient.ResponseStatus

## Response body constants for AWS Cognito operations.
class ResponseBody:
	const ACCESS_TOKEN = "AccessToken"
	const AUTHENTICATION_RESULT = "AuthenticationResult"
	const USER_ATTRIBUTES = "UserAttributes"

## User attribute constants and functions.
class UserAttributes:
	## Generates a custom attribute name.
	## @param name The name of the custom attribute.
	## @return The formatted custom attribute name.
	static func CUSTOM(name: String):
		return "custom:" + name
	
	# Standard user attribute constants
	const NAME = "name"
	const FAMILY_NAME = "family_name"
	const GIVEN_NAME = "given_name"
	const MIDDLE_NAME = "middle_name"
	const NICKNAME = "nickname"
	const PREFERRED_NAME = "preferred_username"
	const PROFILE = "profile"
	const PICTURE = "picture"
	const WEBSITE = "website"
	const GENDER = "gender"
	const BIRTHDATE = "birthdate"
	const ZONEINFO = "zoneinfo"
	const LOCALE = "locale"
	const UPDATED_AT = "updated_at"
	const ADDRESS = "address"
	const EMAIL = "email"
	const PHONE_NUMBER = "phone_number"
	const SUB = "sub"
