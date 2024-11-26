class_name AWSAmplifyData
extends Node

class Config:
	const URL = "url"

enum GraphQLMethod {
	QUERY,
	MUTATION,
	SUBSCRIPTION
}

var _client: AWSAmplifyClient
var _auth: AWSAmplifyAuth
var _config: Dictionary
var _endpoint: String

func query(operation, operation_name = "MyQuery", authenticated: bool = true):
	return await send(operation, operation_name, GraphQLMethod.QUERY, authenticated)

func mutation(operation, operation_name = "MyMutation", authenticated: bool = true):
	return await send(operation, operation_name, GraphQLMethod.MUTATION, authenticated)

func subscription(operation, operation_name = "MySubscription", authenticated: bool = true):
	return await send(operation, operation_name, GraphQLMethod.SUBSCRIPTION, authenticated)

func send(operation, operation_name, method: GraphQLMethod, authenticated: bool = true):
	var headers = [ 
		"Content-Type: application/json"
	]
	
	var operation_type: String
	if method == GraphQLMethod.QUERY:
		operation_type = "query"
	elif method == GraphQLMethod.MUTATION:
		operation_type = "mutation"
	elif method == GraphQLMethod.SUBSCRIPTION:
		operation_type = "subscription"
	else:
		assert("GraphQL method must be one of: query, muration or subscription")
	
	var body = {
		"query": """%s %s { \n	%s \n}""" % [operation_type, operation_name, operation],
		"variables": null,
		"operationName": operation_name
	}
	
	if authenticated:
		return await _auth.post_json(_endpoint, headers, body)
	else:
		return await _client.post_json(_endpoint, headers, body)

func _init(client: AWSAmplifyClient, auth: AWSAmplifyAuth, config: Dictionary) -> void:
	_client = client
	_auth = auth
	_config = config
	_endpoint = _config[Config.URL]
