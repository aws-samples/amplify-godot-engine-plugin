class_name AWSAmplifyClient
extends Node

func get_json(endpoint: String, headers: Array, json_body: Dictionary):
	return await send_json(endpoint, headers, HTTPClient.METHOD_GET , json_body)

func post_json(endpoint: String, headers: Array, json_body: Dictionary):
	return await send_json(endpoint, headers, HTTPClient.METHOD_POST, json_body)

func put_json(endpoint: String, headers: Array, json_body: Dictionary):
	return await send_json(endpoint, headers, HTTPClient.METHOD_PUT, json_body)

func delete_json(endpoint: String, headers: Array, body: Dictionary):
	return await send_json(endpoint, headers, HTTPClient.METHOD_DELETE, body)

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

func get_(endpoint: String, headers: Array, body: String):
	return await send(endpoint, headers, HTTPClient.METHOD_GET , body)

func post(endpoint: String, headers: Array, body: String):
	return await send(endpoint, headers, HTTPClient.METHOD_POST, body)

func put(endpoint: String, headers: Array, body: String):
	return await send(endpoint, headers, HTTPClient.METHOD_PUT, body)

func delete(endpoint: String, headers: Array, body: String):
	return await send(endpoint, headers, HTTPClient.METHOD_DELETE, body)

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

func _success(result):
	return _response(ResponseStatus.SUCCESS, result, null)
	
func _error(status, error):
	return _response(status, null, error)

func _response(status: ResponseStatus, result, error):
	if status == ResponseStatus.SUCCESS:
		return Response.new(status, result, null)
	else:
		return Response.new(status, null, error)

enum ResponseStatus {
	SUCCESS,
	CLIENT_ERROR,
	REQUEST_ERROR,
	HTTP_ERROR,
	JSON_ERROR,
}

class Response:
	var status: ResponseStatus
	var result: Variant
	var error: Variant
	
	func _init(_status: ResponseStatus, _result: Variant, _error: Variant):
		status = _status
		result = _result
		error = _error
