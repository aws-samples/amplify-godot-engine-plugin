class_name AWSAmplifyClient
extends AWSAmplifyBase

func make_http_get(endpoint, headers, body):
	return await make_http_request(endpoint, headers, HTTPClient.METHOD_GET , body)

func make_http_post(endpoint, headers, body):
	return await make_http_request(endpoint, headers, HTTPClient.METHOD_POST, body)

func make_http_put(endpoint, headers, body):
	return await make_http_request(endpoint, headers, HTTPClient.METHOD_PUT, body)

func make_http_delete(endpoint, headers, body):
	return await make_http_request(endpoint, headers, HTTPClient.METHOD_DELETE, body)

func make_http_request(endpoint, headers, method, body):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var http_request_body: String
	if body is Dictionary:
		http_request_body = JSON.stringify(body)
	elif body is String:
		http_request_body = body
	else:
		assert(false, "body must be either Dictionary or String!")
	
	var error = http_request.request(endpoint, headers, method, http_request_body)
	if error != OK:
		return _generate_response_json(false, "Failed to send request", 400, null, error)
		
	var response = await http_request.request_completed
	http_request.queue_free()
	
	var result = response[0]
	var response_code = response[1]
	var response_headers = response[2]
	var response_body = response[3]
	
	if result == HTTPRequest.RESULT_SUCCESS:
		var json = JSON.parse_string(response_body.get_string_from_utf8())
		if !json:
			if response_code >= 200 && response_code < 300:
				return _generate_response_json(true, "Response not in json", response_code, response_headers, result)
			return _generate_response_json(false, "Failed to parse the response body", response_code, response_headers, result)
		if response_code != 200:
			return _generate_response_json(false, json, response_code, response_headers, result)
		return _generate_response_json(true, json, response_code, response_headers, result)
	else:
		return _generate_response_json(false, response_body, response_code, response_headers, result)
		
func _generate_response_json(success, response_body, response_code, response_headers, result):
	return {
		"success": success,
		"response_body": response_body,
		"response_code": response_code,
		"response_headers": response_headers,
		"result": result
	}
