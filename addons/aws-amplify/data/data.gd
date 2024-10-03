class_name AWSData
extends Node

var graphql_endpoint = ''

func mutate(query, operation_name):
	var headers = [
		"Content-Type: application/json"
	]
	
	var body = JSON.stringify({
		"query": "mutation " + operation_name + " " + query,
		"variables": null,
		"operationName": operation_name
	})
	
	return await AWSAmplify.api_client.make_authenticated_request(graphql_endpoint, headers, HTTPClient.METHOD_POST, body)
