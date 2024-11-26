class_name AWSAmplifyData
extends Node
## A class for handling AWS Amplify data operations.
##
## This class provides methods for performing GraphQL queries, mutations, 
## and subscriptions using AWS Amplify. It handles authentication and 
## request formatting.

## Performs a GraphQL query operation.
##
## @param operation The GraphQL query string.
## @param operation_name The name of the query operation.
## @param authenticated Whether the request should be authenticated.
## @return The result of the query operation.
func query(operation, operation_name = "MyQuery", authenticated: bool = true):
	return await send(operation, operation_name, GraphQLMethod.QUERY, authenticated)

## Performs a GraphQL mutation operation.
##
## @param operation The GraphQL mutation string.
## @param operation_name The name of the mutation operation.
## @param authenticated Whether the request should be authenticated.
## @return The result of the mutation operation.
func mutation(operation, operation_name = "MyMutation", authenticated: bool = true):
	return await send(operation, operation_name, GraphQLMethod.MUTATION, authenticated)

## Performs a GraphQL subscription operation.
##
## @param operation The GraphQL subscription string.
## @param operation_name The name of the subscription operation.
## @param authenticated Whether the request should be authenticated.
## @return The result of the subscription operation.
func subscription(operation, operation_name = "MySubscription", authenticated: bool = true):
	return await send(operation, operation_name, GraphQLMethod.SUBSCRIPTION, authenticated)

## Sends a GraphQL request to the API endpoint.
##
## @param operation The GraphQL operation string.
## @param operation_name The name of the operation.
## @param method The GraphQL method type (query, mutation, or subscription).
## @param authenticated Whether the request should be authenticated.
## @return The result of the GraphQL operation.
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
		assert("GraphQL method must be one of: query, mutation or subscription")
	
	var body = {
		"query": """%s %s { \n    %s \n}""" % [operation_type, operation_name, operation],
		"variables": null,
		"operationName": operation_name
	}
	
	if authenticated:
		return await _auth.post_json(_endpoint, headers, body)
	else:
		return await _client.post_json(_endpoint, headers, body)

## Initializes the AWSAmplifyData instance.
##
## @param client The AWSAmplifyClient instance.
## @param auth The AWSAmplifyAuth instance.
## @param config The configuration dictionary.
func _init(client: AWSAmplifyClient, auth: AWSAmplifyAuth, config: Dictionary) -> void:
	_client = client
	_auth = auth
	_config = config
	_endpoint = _config[Config.URL]

## Configuration constants for the AWSAmplifyData class.
class Config:
	## The URL key for the API endpoint.
	const URL = "url"

## Enum representing different GraphQL operation types.
enum GraphQLMethod {
	QUERY,
	MUTATION,
	SUBSCRIPTION
}

## The AWS Amplify client instance.
var _client: AWSAmplifyClient

## The AWS Amplify authentication instance.
var _auth: AWSAmplifyAuth

## Configuration dictionary for the AWSAmplifyData instance.
var _config: Dictionary

## The API endpoint URL.
var _endpoint: String
