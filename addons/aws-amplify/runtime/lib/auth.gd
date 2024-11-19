class_name AWSAmplifyAuth  
extends AWSAmplifyBase
		
class CONFIG:
	const REGION = "aws_region"
	const CLIENT_ID = "user_pool_client_id"

class TOKEN:
	const ACCESS_TOKEN = "AccessToken"
	const ACCESS_TOKEN_EXPIRATION_TIME = "AccessTokenExpirationTime"
	const REFRESH_TOKEN = "RefreshToken"	

class JWT:
	const HEADER = "header"
	const PAYLOAD = "payload"
	const VERIFIED_SIGNATURE = "verified_signature"
	
var _client: AWSAmplifyClient
var _config: Dictionary
var _endpoint: String
var _client_id: String

var _tokens: Dictionary
var _user_attributes: Dictionary

signal user_signed_in
signal user_changed
signal user_signed_out
signal user_signed_up

func _init(client: AWSAmplifyClient, config: Dictionary) -> void:
	_client = client
	_config = config
	_client_id = config[CONFIG.CLIENT_ID]
	_endpoint = "https://cognito-idp." + config[CONFIG.REGION] + ".amazonaws.com/"
	_tokens = {}
	_user_attributes = {}

func is_user_signed_in():
	return (
		_tokens.has(TOKEN.ACCESS_TOKEN) && 
		_get_access_token_expiration_time(_tokens[TOKEN.ACCESS_TOKEN]) > Time.get_unix_time_from_system()
	)

func get_user_attribute(name: String, refresh_attributes = false):
	return get_user_attributes(refresh_attributes)[name]

func get_user_attributes(refresh_attributes = false):
	refresh_user(refresh_attributes)
	return _user_attributes
	
func get_user_access_token_expiration_time() -> int:
	if _tokens.has(TOKEN.ACCESS_TOKEN):
		return _get_access_token_expiration_time(_tokens[TOKEN.ACCESS_TOKEN])
	else:
		return Time.get_unix_time_from_system()
	
func add_user_attributes(_user_attributes: Dictionary = {}):
	var attributes = _user_attributes
	attributes.merge(_user_attributes)
	return await update_user_attributes(attributes)
	
func remove_user_attributes(keys: Array):
	var attributes = _user_attributes
	for key in _user_attributes.keys():
		if not keys.has(key):
			attributes[key] = _user_attributes[key]
	return await update_user_attributes(attributes)

func update_user_attributes(__user_attributes: Dictionary = {}):
	var attributes = []
	for key in __user_attributes.keys():
		attributes.append({
			"Name": key,
			"Value": __user_attributes[key]
		})
	
	var headers = [
		HEADERS.X_AMZ_TARGET("UpdateUserAttributes"),
		HEADERS.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1
	]
	
	var body = {
		BODY.CLIENT_ID: _client_id,
		BODY.USER_ATTRIBUTES: attributes,
		BODY.ACCESS_TOKEN: _tokens[TOKEN.ACCESS_TOKEN]
	}

	var response = await _client.make_http_post(_endpoint, headers, body)
	if response.success:
		_user_attributes = __user_attributes
		user_changed.emit(_user_attributes)
	return response

func refresh_user(refresh_access_token = false, refresh_attributes = false):
	if _tokens.has(TOKEN.ACCESS_TOKEN):
		# refresh user access token if user access token has expired
		if (refresh_access_token or 
			(_tokens[TOKEN.ACCESS_TOKEN_EXPIRATION_TIME] < Time.get_unix_time_from_system() and 
			 _tokens[TOKEN.REFRESH_TOKEN])):
			var response = await _refresh_user_access_token(_tokens[TOKEN.REFRESH_TOKEN])
			if not response.success:
				_clean_tokens()
		
		# refresh user attributes
		if refresh_attributes:
			var response = await _refresh_user_attributes(_tokens[TOKEN.ACCESS_TOKEN])
			if response.success:
				user_changed.emit(_user_attributes)
			else:
				_clean_tokens()
		else:
			user_changed.emit(_user_attributes)
	else:
		_clear_user_attributes()

func sign_in_with_username_password(username, password, auth_mode: AuthMode = AuthMode.EMAIL):
	var headers = [
		HEADERS.X_AMZ_TARGET("InitiateAuth"),
		HEADERS.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1
	]
	
	var body = {
		BODY.CLIENT_ID: _client_id,
		BODY.AUTH_FLOW: "USER_PASSWORD_AUTH",
		BODY.AUTH_PARAMETERS: {
			"USERNAME": username,
			"PASSWORD": password
		}
	}

	var response = await _client.make_http_post(_endpoint, headers, body)
	if response.success:
		_user_attributes = {}
		if AuthMode.EMAIL:
			_user_attributes[USER_ATTRIBUTES.EMAIL] = username			
		else:
			_user_attributes[USER_ATTRIBUTES.PHONE_NUMBER] = username	

		var response_body = response.response_body
		if response_body.has(BODY.AUTHENTICATED_RESULT) and response_body[BODY.AUTHENTICATED_RESULT].has(BODY.ACCESS_TOKEN):
			
			var authenticated_result = response_body[BODY.AUTHENTICATED_RESULT]
			_tokens[TOKEN.ACCESS_TOKEN] = authenticated_result[BODY.ACCESS_TOKEN]
			_tokens[TOKEN.ACCESS_TOKEN_EXPIRATION_TIME] = _get_access_token_expiration_time(_tokens[TOKEN.ACCESS_TOKEN])
			_tokens[TOKEN.REFRESH_TOKEN] = authenticated_result[BODY.REFRESH_TOKEN]
			
			var refresh_user_attributes_response = await _refresh_user_attributes(_tokens[TOKEN.ACCESS_TOKEN])
			if refresh_user_attributes_response.success:
				user_signed_in.emit(_user_attributes)
			else:
				_clear_user_attributes()
			return refresh_user_attributes_response
		
	return response

func forgot_password(email):
	var headers = [
		HEADERS.X_AMZ_TARGET("ForgotPassword"),
		HEADERS.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1
	]

	var body = {
		BODY.CLIENT_ID: _client_id,
		BODY.USERNAME: email
	}

	return await _client.make_http_post(_endpoint, headers, body)

func forgot_password_confirm_code(email, confirmation_code, new_password):
	var headers = [
		HEADERS.X_AMZ_TARGET("ConfirmForgotPassword"),
		HEADERS.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1
	]

	var body = {
		BODY.CLIENT_ID: _client_id,
		BODY.USERNAME: email,
		BODY.CONFIRMATION_CODE: confirmation_code,
		BODY.PASSWORD: new_password
	}

	return await _client.make_http_post(_endpoint, headers, body)

func global_sign_out():
	var headers = [
		HEADERS.X_AMZ_TARGET("GlobalSignOut"),
		HEADERS.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1
	]

	var body = {
		BODY.CLIENT_ID: _client_id,
		BODY.ACCESS_TOKEN: _tokens[TOKEN.ACCESS_TOKEN]
	}
	
	var response = await _client.make_http_post(_endpoint, headers, body)
	if response.success:
		user_signed_out.emit(_user_attributes)
		_clean_tokens()
	return response
	
func sign_up(email, password, options = {}):
	var headers = [
		HEADERS.X_AMZ_TARGET("SignUp"),
		HEADERS.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1
	]

	var body = {
		BODY.CLIENT_ID: _client_id,
		BODY.USERNAME: email,
		BODY.PASSWORD: password
	}

	if !options.is_empty() && options.has("userAttributes"):
		var userAttributes = options["userAttributes"]
		var userAttributesArray = []

		for key in userAttributes:
			userAttributesArray.append({
				"Name": key,
				"Value": userAttributes[key]
			})

		body[BODY.USER_ATTRIBUTES] = userAttributesArray
	
	var response = await _client.make_http_post(_endpoint, headers, body)
	if response.success:
		user_signed_up.emit()
	return response

func sign_up_confirm_code(email, confirmation_code):
	var headers = [
		HEADERS.X_AMZ_TARGET("ConfirmSignUp"),
		HEADERS.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1
	]

	var body = {
		BODY.CLIENT_ID: _client_id,
		BODY.USERNAME: email,
		BODY.CONFIRMATION_CODE: confirmation_code
	}

	return await _client.make_http_post(_endpoint, headers, body)

func sign_up_resend_code(email):
	var headers = [
		HEADERS.X_AMZ_TARGET("ResendConfirmationCode"),
		HEADERS.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1
	]

	var body = {
		BODY.CLIENT_ID: _client_id,
		BODY.USERNAME: email
	}
	
	return await _client.make_http_post(_endpoint, headers, body)

func make_authenticated_http_get(endpoint, headers, body):
	return await make_authenticated_http_request(endpoint, headers, HTTPClient.METHOD_GET , body)

func make_authenticated_http_post(endpoint, headers, body):
	return await make_authenticated_http_request(endpoint, headers, HTTPClient.METHOD_POST, body)

func make_authenticated_http_put(endpoint, headers, body):
	return await make_authenticated_http_request(endpoint, headers, HTTPClient.METHOD_PUT, body)

func make_authenticated_http_delete(endpoint, headers, body):
	return await make_authenticated_http_request(endpoint, headers, HTTPClient.METHOD_DELETE, body)

func make_authenticated_http_request(endpoint, headers, method, body):
	# automatically refresh access token if expired
	refresh_user()
	# append access token to the authorization bearer
	headers.append(HEADERS.AUTHORIZATION_BEARER(_tokens[TOKEN.ACCESS_TOKEN]))
	return await _client.make_http_request(endpoint, headers, method, body)

func _refresh_user_access_token(refresh_token):
	var headers = [
		HEADERS.X_AMZ_TARGET("InitiateAuth"),
		HEADERS.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1
	]
	
	var body = {
		BODY.CLIENT_ID: _client_id,
		BODY.AUTH_FLOW:"REFRESH_TOKEN_AUTH",
		BODY.AUTH_PARAMETERS: {
			"REFRESH_TOKEN": refresh_token
		}
	}
	
	var response = await _client.make_http_post(_endpoint, headers, body)
	var response_body = response.response_body
	if response_body.has(BODY.AUTHENTICATED_RESULT) and response_body[BODY.AUTHENTICATED_RESULT].has(BODY.ACCESS_TOKEN):
		_tokens[TOKEN.ACCESS_TOKEN] = response_body[BODY.AUTHENTICATED_RESULT][BODY.ACCESS_TOKEN]
		_tokens[TOKEN.ACCESS_TOKEN_EXPIRATION_TIME] = _get_access_token_expiration_time(_tokens[TOKEN.ACCESS_TOKEN])
	return response
	
func _refresh_user_attributes(access_token):
	var headers = [
		HEADERS.X_AMZ_TARGET("GetUser"),
		HEADERS.CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1
	]
	
	var body = {
		BODY.ACCESS_TOKEN: access_token,
	}

	var response = await _client.make_http_post(_endpoint, headers, body)
	if response.success:
		var attributes = response.response_body[BODY.USER_ATTRIBUTES]
		for attribute in attributes:
			_user_attributes[attribute.Name] = attribute.Value
	return response

func _clean_tokens():
	_tokens.clear()
	_clear_user_attributes()

func _clear_user_attributes():
	_user_attributes.clear()
	user_changed.emit(_user_attributes)

func _get_access_token_expiration_time(access_token):
	var decoded_token = _decode_jwt(access_token)
	var token_payload = decoded_token.payload
	return token_payload.exp

func _decode_jwt(token):
	var parts = token.split(".")
	
	assert(parts.size() == 3, "JWT Token must have 3 parts: header, payload and verified signature.")
	
	var header_string = Marshalls.base64_to_utf8(parts[0]) # Fix bug and create an issue in godot for base64_to_utf8
	var header = JSON.parse_string(header_string)
	var payload_string = Marshalls.base64_to_utf8(parts[1])
	var payload = JSON.parse_string(payload_string)
	# var verified_signature_string = Marshalls.base64_to_utf8(parts[2])
	# var verified_signature = JSON.parse_string(verified_signature_string)
	
	return {
		JWT.HEADER: header, 
		JWT.PAYLOAD: payload, 
		# JWT.VERIFIED_SIGNATURE: verified_signature
	}
