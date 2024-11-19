class_name AWSAmplifyData
extends AWSAmplifyBase

class CONFIG:
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

func make_graphql_query(operation, operation_name = "MyQuery", authenticated: bool = true):
	return await make_graphql_request(operation, operation_name, GraphQLMethod.QUERY, authenticated)

func make_graphql_mutation(operation, operation_name = "MyMutation", authenticated: bool = true):
	return await make_graphql_request(operation, operation_name, GraphQLMethod.MUTATION, authenticated)

func make_graphql_subscription(operation, operation_name = "MySubscription", authenticated: bool = true):
	return await make_graphql_request(operation, operation_name, GraphQLMethod.SUBSCRIPTION, authenticated)

func make_graphql_request(operation, operation_name, method: GraphQLMethod, authenticated: bool = true):
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
		return await _auth.make_authenticated_http_post(_endpoint, headers, body)
	else:
		return await _client.make_http_post(_endpoint, headers, body)

func _init(client: AWSAmplifyClient, auth: AWSAmplifyAuth, config: Dictionary) -> void:
	_client = client
	_auth = auth
	_config = config
	_endpoint = _config[CONFIG.URL]
