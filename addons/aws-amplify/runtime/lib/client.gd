## AWS Amplify client class for handling HTTP requests.
##
## This class provides methods for sending HTTP requests to AWS Amplify endpoints
## and handling responses.
class_name AWSAmplifyClient
extends Node

## Sends a GET request with JSON body.
##
## [param endpoint]: The URL endpoint for the request.
## [param headers]: An array of headers to be sent with the request.
## [param json_body]: A dictionary representing the JSON body of the request.
## [return]: A Response object containing the result or error.
func get_json(endpoint: String, headers: Array, json_body: Dictionary):
	return await send_json(endpoint, headers, HTTPClient.METHOD_GET , json_body)

## Sends a POST request with JSON body.
##
## [param endpoint]: The URL endpoint for the request.
## [param headers]: An array of headers to be sent with the request.
## [param json_body]: A dictionary representing the JSON body of the request.
## [return]: A Response object containing the result or error.
func post_json(endpoint: String, headers: Array, json_body: Dictionary):
	return await send_json(endpoint, headers, HTTPClient.METHOD_POST, json_body)

## Sends a PUT request with JSON body.
##
## [param endpoint]: The URL endpoint for the request.
## [param headers]: An array of headers to be sent with the request.
## [param json_body]: A dictionary representing the JSON body of the request.
## [return]: A Response object containing the result or error.
func put_json(endpoint: String, headers: Array, json_body: Dictionary):
	return await send_json(endpoint, headers, HTTPClient.METHOD_PUT, json_body)

## Sends a DELETE request with JSON body.
##
## [param endpoint]: The URL endpoint for the request.
## [param headers]: An array of headers to be sent with the request.
## [param body]: A dictionary representing the body of the request.
## [return]: A Response object containing the result or error.
func delete_json(endpoint: String, headers: Array, body: Dictionary):
	return await send_json(endpoint, headers, HTTPClient.METHOD_DELETE, body)

## Sends a request with JSON body using the specified HTTP method.
##
## [param endpoint]: The URL endpoint for the request.
## [param headers]: An array of headers to be sent with the request.
## [param method]: The HTTP method to use for the request.
## [param json_body]: A dictionary representing the JSON body of the request.
## [return]: A Response object containing the result or error.
func send_json(endpoint: String, headers: Array, method: HTTPClient.Method, json_body: Dictionary):
	var body = JSON.stringify(json_body)
	if not body:
		_error(ResponseStatus.JSON_ERROR, "request body is not json: %s" % json_body)
	
	var response = await send(endpoint, headers, method, body)
	var response_value = response.result if (response.status == ResponseStatus.SUCCESS) else response.error
	
	var json_response_value = JSON.parse_string(response_value)
	if !json_response_value:
		_error(ResponseStatus.JSON_ERROR, "response result is not json: %s" % response_value)
		
	if response.status == ResponseStatus.SUCCESS:
		return _success(json_response_value) 
	else: 
		return _error(response.status, json_response_value)

## Sends a GET request.
##
## [param endpoint]: The URL endpoint for the request.
## [param headers]: An array of headers to be sent with the request.
## [param body]: The body of the request as a string.
## [return]: A Response object containing the result or error.
func get_(endpoint: String, headers: Array, body: String):
	return await send(endpoint, headers, HTTPClient.METHOD_GET , body)

## Sends a POST request.
##
## [param endpoint]: The URL endpoint for the request.
## [param headers]: An array of headers to be sent with the request.
## [param body]: The body of the request as a string.
## [return]: A Response object containing the result or error.
func post(endpoint: String, headers: Array, body: String):
	return await send(endpoint, headers, HTTPClient.METHOD_POST, body)

## Sends a PUT request.
##
## [param endpoint]: The URL endpoint for the request.
## [param headers]: An array of headers to be sent with the request.
## [param body]: The body of the request as a string.
## [return]: A Response object containing the result or error.
func put(endpoint: String, headers: Array, body: String):
	return await send(endpoint, headers, HTTPClient.METHOD_PUT, body)

## Sends a DELETE request.
##
## [param endpoint]: The URL endpoint for the request.
## [param headers]: An array of headers to be sent with the request.
## [param body]: The body of the request as a string.
## [return]: A Response object containing the result or error.
func delete(endpoint: String, headers: Array, body: String):
	return await send(endpoint, headers, HTTPClient.METHOD_DELETE, body)

## Sends an HTTP request using the specified method.
##
## [param endpoint]: The URL endpoint for the request.
## [param headers]: An array of headers to be sent with the request.
## [param method]: The HTTP method to use for the request.
## [param body]: The body of the request as a string.
## [return]: A Response object containing the result or error.
func send(endpoint: String, headers: Array, method: HTTPClient.Method, body: String) -> Response:
	var http_request = HTTPRequest.new()
	add_child(http_request)

	var error = http_request.request(endpoint, headers, method, body)
	if error:
		return _error(ResponseStatus.CLIENT_ERROR, "http client error: %a")

	var response = await http_request.request_completed
	http_request.queue_free()

	var result = response[0]
	var response_code = response[1]
	var response_headers = response[2]
	var response_body = response[3].get_string_from_utf8()

	if result == HTTPRequest.RESULT_SUCCESS:
		if response_code != 200:
			return _error(ResponseStatus.HTTP_ERROR, response_body)
		else:
			return _success(response_body)
	else:
		return _error(ResponseStatus.REQUEST_ERROR, response_body)

## Creates a success response.
##
## [param result]: The result to be included in the response.
## [return]: A Response object with a success status.
func _success(result):
	return _response(ResponseStatus.SUCCESS, result, null)

## Creates an error response.
##
## [param status]: The error status.
## [param error]: The error message or object.
## [return]: A Response object with an error status.
func _error(status, error):
	return _response(status, null, error)

## Creates a response object.
##
## [param status]: The response status.
## [param result]: The result of the request (if successful).
## [param error]: The error message or object (if an error occurred).
## [return]: A Response object.
func _response(status: ResponseStatus, result, error):
	if status == ResponseStatus.SUCCESS:
		return Response.new(status, result, null)
	else:
		return Response.new(status, null, error)

## Enum representing possible response statuses.
enum ResponseStatus {
	SUCCESS,
	CLIENT_ERROR,
	REQUEST_ERROR,
	HTTP_ERROR,
	JSON_ERROR,
}

## Class representing an HTTP response.
class Response:
	## The status of the response.
	var status: ResponseStatus
	## The result of the request (if successful).
	var result: Variant
	## The error message or object (if an error occurred).
	var error: Variant
	
	## Initializes a new Response instance.
	##
	## [param _status]: The status of the response.
	## [param _result]: The result of the request (if successful).
	## [param _error]: The error message or object (if an error occurred).
	func _init(_status: ResponseStatus, _result: Variant, _error: Variant):
		status = _status
		result = _result
		error = _error
