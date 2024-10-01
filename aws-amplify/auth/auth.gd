extends Node

var auth_token = ''
var refresh_token = ''
var client_id = ''
var cognito_endpoint = ''
var token_timeout_delay = 120
var current_user
		
func sign_in_with_user_password(email, password):
	var headers = [
		"X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth",
		"Content-Type: application/x-amz-json-1.1"
	]
	
	var body = JSON.stringify({
		"AuthFlow": "USER_PASSWORD_AUTH",
		"ClientId": client_id,
		"AuthParameters": {
			"USERNAME": email,
			"PASSWORD": password
		}
	})
	
	var response = await AwsAmplify.api_client.make_request(cognito_endpoint, headers, HTTPClient.METHOD_POST, body)
	var json = response.response_body
	if json.has("AuthenticationResult") and json.AuthenticationResult.has("AccessToken"):
		auth_token = json.AuthenticationResult.AccessToken
		refresh_token = json.AuthenticationResult.RefreshToken
		var user = await get_current_user()
		if !user:
			return false
			
		print("Current User : ", user)
		current_user = user
		return true
	return false
	

func refresh_access_token():
	
	if !refresh_token || refresh_token == '':
		return false
	
	var headers = [
		"X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth",
		"Content-Type: application/x-amz-json-1.1"
	]
	
	var body = JSON.stringify({
		"AuthFlow": "REFRESH_TOKEN_AUTH",
		"ClientId": client_id,
		"AuthParameters": {
			"REFRESH_TOKEN": refresh_token
		}
	})
	
	var response = await AwsAmplify.api_client.make_request(cognito_endpoint, headers, HTTPClient.METHOD_POST, body)
	var json = response.response_body
	if json.has("AuthenticationResult") and json.AuthenticationResult.has("AccessToken"):
		auth_token = json.AuthenticationResult.AccessToken
		return true
	return false
	
	
func get_current_user():
	
	if current_user:
		return current_user
		
	#Add an token helper function to verify there is a token
	
	var headers = [
		"X-Amz-Target: AWSCognitoIdentityProviderService.GetUser",
		"Content-Type: application/x-amz-json-1.1"
	]
	
	var body = JSON.stringify({
		"AccessToken": auth_token,
	})

	var response = await AwsAmplify.api_client.make_request(cognito_endpoint, headers, HTTPClient.METHOD_POST, body)
	var json = response.response_body
	
	if json.has("UserAttributes"):
		var user_attributes = json.UserAttributes
		
		var user = {}
		for item in user_attributes: #create util function for this?
			user[item.Name] = item.Value
		user.Username = json.Username
		return user
		
	return false
	
func get_user_attribute(attribute):
	if current_user == null:
		print("No current user")
		return null
	
	if not current_user.has(attribute):
		print("User does not have attribute attribute")
		return null
	
	var attribute_value = current_user[attribute]
	if attribute_value == null:
		print("attribute is null")
		return null
	
	return attribute_value
	
func handle_authentication():
	if !refresh_token || refresh_token == '':
		return {"success": false, "message": "User in not authenticated"}
	
	if !auth_token || auth_token == '':
		print("refreshing access token 1")
		var success = await refresh_access_token()
		if !success:
			return {"success": false, "message": "Couldn't retrieve refresh token"}
		
	var expiration_delay = get_token_expiration_delay(auth_token)
	print("token expiring in : ", expiration_delay)
	if expiration_delay < token_timeout_delay:
		print("refreshing access token 2")
		var success = await refresh_access_token()
		if !success:
			return {"success": false, "message": "Couldn't retrieve refresh token"}
			
	return {"success": true, "message": "Succesfully retrieved access token"} 

	
func decode_jwt(token):
	var parts = token.split(".")
	if parts.size() != 3:
		return {}
	
	var header = JSON.parse_string(Marshalls.base64_to_utf8(parts[0]))
	var payload = JSON.parse_string(Marshalls.base64_to_utf8(parts[1]))
	
	return {"header": header, "payload": payload}
	

func get_token_expiration_delay(token):
	#error handling to be added
	
	var decoded_token = decode_jwt(token)
	var token_payload = decoded_token.payload

	return token_payload.exp - Time.get_unix_time_from_system()
