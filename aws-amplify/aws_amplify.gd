extends Node

var email = ''

var auth = preload("./auth/auth.gd").new()
var api_client = preload("./api/api_client.gd").new()
var data = preload("./data/data.gd").new()

func _ready():
	
	add_child(auth)
	add_child(api_client)
	add_child(data)
	
	var file_path = "res://amplify_outputs.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(content)
		
		if parse_result == OK:
			var result = json.get_data()
			var auth_data = result["auth"]
			var region = auth_data["aws_region"]
			auth.cognito_endpoint = "https://cognito-idp." + region + ".amazonaws.com/"
			auth.client_id = auth_data["user_pool_client_id"]
			data.graphql_endpoint = result["data"]["url"]
			
		else:
			print("Failed to parse JSON")
	else:
		print("File does not exist: ", file_path)
