## AWS Amplify for Godot Engine - Plugin

This project contains a Godot Engine plugin to interact with AWS Amplify deployed resources on AWS.

## Wiki

The [wiki](https://github.com/aws-samples/amplify-godot-engine/wiki) contains everything you want to know about getting started with AWS Amplify with the Godot Engine.

## Install the Plugin

Download the plugin
1. Go to the [GitHub Release Section](https://github.com/aws-samples/amplify-godot-engine-plugin/releases)
2. Click on the latest release
3. Download the source code
4. Extract the plugin code
5. Copy the addons/aws-amplify folder at the root of your Godot project

Enable the plugin
1. Open Project -> Project Settings -> Plugins -> Enabled (AWS Amplify)
2. The plugin autload the ```aws_amplify``` singleton when enabled

The AWS Amplify Plugin is ready to be used!

## Architecture the Plugin

The plugin is organized in the same way as the [amplify-js](https://github.com/aws-amplify/amplify-js) client.
The base class AWSAmplify contains several module, each of them implementing specific features.
You can access each module from the base class direcly:

```aws_amplify.client``` will give you access to the client module

## [Client (client)](https://github.com/aws-samples/amplify-godot-engine-plugin/blob/main/addons/aws-amplify/runtime/lib/client.gd) 

This module offers basic features to send http requests to AWS resources.

Here's a list of all the functions with their parameters from the provided AWSAmplifyClient class:

### Http Requests (TEXT)

You can send http request and receive responses, with plain text bodies:
- `get_(endpoint: String, headers: Array, body: String)`
- `post(endpoint: String, headers: Array, body: String)`
- `put(endpoint: String, headers: Array, body: String)`
- `delete(endpoint: String, headers: Array, body: String)`
- `send(endpoint: String, headers: Array, method: HTTPClient.Method, body: String)`

### Http Requests (JSON)

You can send http request and receive responses, with JSON bodies:
- `get_json(endpoint: String, headers: Array, json_body: Dictionary)`
- `post_json(endpoint: String, headers: Array, json_body: Dictionary)`
- `put_json(endpoint: String, headers: Array, json_body: Dictionary)`
- `delete_json(endpoint: String, headers: Array, body: Dictionary)`
- `send_json(endpoint: String, headers: Array, method: HTTPClient.Method, json_body: Dictionary)`

This module is used in other modules such as ```auth``` and ```data```.

## [Authentication (auth)](https://github.com/aws-samples/amplify-godot-engine-plugin/blob/main/addons/aws-amplify/runtime/lib/auth.gd)

This module offers authentication features. 

### Sign-Up
- `sign_up(username, password, options: Dictionary = {})`
- `confirm_sign_up(username: String, confirmation_code: String, options: Dictionary = {})`
- `resend_sign_up_code(username, options: Dictionary = {})`

### Sign-In
- `sign_in(username, password, options: Dictionary = {})`
- `reset_password(username, options: Dictionary = {})`
- `confirm_reset_password(username, new_password, confirmation_code, options: Dictionary = {})`
- `update_password(old_password, new_password, options: Dictionary = {})`

### Sign-Out
- `sign_out(global: bool = false)`
- `refresh_token(refresh_token)`

### User Attributes
- `update_user_attributes(user_attributes: Dictionary, options: Dictionary = {})`
- `update_user_attribute(user_attribute_name: String, user_attribute_value, options: Dictionary = {})`
- `confirm_user_attribute(attribute_name: String, confirmation_code: String, options: Dictionary = {})`
- `send_user_attribute_confirmation_code(attribute_name: String, confirmation_code: String, options: Dictionary = {})`
- `delete_user_attributes(user_attribute_names: Array[String])`

### Cached variables manipulation (tokens and user attributes)
- `get_token(name)`
- `get_user_attribute(name: String, refresh_attributes = false)`
- `get_user_attributes(refresh_attributes = false)`
- `add_user_attributes(user_attributes: Dictionary)`
- `remove_user_attributes(keys: Array)`
- `refresh_user(refresh_token = false, refresh_user_attributes = false)`

### Authenticated http request (TEXT)
- `get_(endpoint: String, headers: Array, body: String)`
- `post(endpoint: String, headers: Array, body: String)`
- `put(endpoint: String, headers: Array, body: String)`
- `delete(endpoint: String, headers: Array, body: String)`
- `send(endpoint: String, headers: Array, method: HTTPClient.Method, body: String)`

### Authenticated http request (JSON)
- `get_json(endpoint: String, headers: Array, json_body: Dictionary)`
- `post_json(endpoint: String, headers: Array, json_body: Dictionary)`
- `put_json(endpoint: String, headers: Array, json_body: Dictionary)`
- `delete_json(endpoint: String, headers: Array, body: Dictionary)`
- `send_json(endpoint: String, headers: Array, method: HTTPClient.Method, json_body: Dictionary)`

## [Data (data)](https://github.com/aws-samples/amplify-godot-engine-plugin/blob/main/addons/aws-amplify/runtime/lib/data.gd)

This module offers GraphQL features.

Here's a list of all the functions defined in the AWSAmplifyData class:

- `query(operation, operation_name = "MyQuery", authenticated: bool = true)`
- `mutation(operation, operation_name = "MyMutation", authenticated: bool = true)`
- `subscription(operation, operation_name = "MySubscription", authenticated: bool = true)`
- `send(operation, operation_name, method: GraphQLMethod, authenticated: bool = true)`

## [UI (AuthForm)](https://github.com/aws-samples/amplify-godot-engine-plugin/blob/main/addons/aws-amplify/runtime/ui/auth_form.gd)

The plugin offers an various forms to handle authentication flow. 

## Discussions

If you have a question or you want to discuss with the AWS Amplify for Godot Engine community go to the main project [discussions](https://github.com/aws-samples/amplify-godot-engine/discussions) channels.

## Issues

If you have any issue with a custom build image [report a bug](https://github.com/aws-samples/amplify-godot-engine-plugin/issues/new?assignees=&labels=&projects=&template=bug_report.md&title=) and if you need a new image or something else  [create a feature request](https://github.com/aws-samples/amplify-godot-engine-plugin/issues/new?assignees=&labels=&projects=&template=feature_request.md&title=).

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the [LICENSE](LICENSE.md) file.

## Third Party Licenses

See [THIRD_PARTY_LICENSES](THIRD_PARTY_LICENSES) for more information.