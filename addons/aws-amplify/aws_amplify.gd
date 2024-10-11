extends Node

var email = ''

const AuthClass := preload("./auth/auth.gd")
const APIClientClass := preload("./api/api_client.gd")
const DataClass := preload("./data/data.gd")

static var auth: AWSAuth
static var api_client: AWSAPIClient
static var data: AWSData
	
func _init():
	auth = AuthClass.new()
	api_client = APIClientClass.new()
	data = DataClass.new()

func _ready():
	
	add_child(api_client)
	
	var file_path = "res://amplify_outputs.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(content)
		
		if parse_result == OK:
			var result = json.get_data()
			if result.has("auth"):
				var auth_data = result["auth"]
				var region = auth_data["aws_region"]
				auth.cognito_endpoint = "https://cognito-idp." + region + ".amazonaws.com/"
				auth.client_id = auth_data["user_pool_client_id"]
			if result.has("data"):
				data.graphql_endpoint = result["data"]["url"]
			
		else:
			print("Failed to parse JSON")
	else:
		print("File does not exist: ", file_path)
