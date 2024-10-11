## AWS Amplify for Godot Engine - Plugin

This project contains a Godot Engine plugin to interact with AWS Amplify deployed resources on AWS.

## Wiki

The [wiki](https://github.com/aws-samples/amplify-godot-engine/wiki) contains everything you want to know about getting started with AWS Amplify with the Godot Engine.

## Install the Plugin

Clone the repository and copy the addons folder at the root of your project. 

Then you can add the autoload for the plugin by in the Godot project settings
1. Open Project -> Project Settings -> Globals -> Autoload
2. For path, select aws_amplify.gd (under addons/aws_amplify) 
3. Change the node name to AWSAmplify
4. Click Add and make sur the global variable is enabled

The Plugin is ready to be used

## Authentication

The plugin provides utils functions for authentication, by allowing users to login, and do subsequent authenticated API calls with the `make_authenticated_request` function. 
Once successfully signed, the plugin will automatically manage the access and refresh token logic.

### sign_in_with_user_password

```sign_in_with_user_password(email: String, password: String) -> bool```


Signs in a user with their email and password.

**Input:**
- `email` (String): User's email address
- `password` (String): User's password

**Output:**
- `Boolean`: True if sign-in is successful, False otherwise

**Description:**
This function initiates the USER_PASSWORD_AUTH flow with AWS Cognito. It sends the user's credentials and retrieve an access token, refresh token and the user's attributes upon successful authentication. It will then be possible to make authenticated requests.

### sign_up

```sign_up(email: String, password: String, options: Dictionary = {}) -> Dictionary```

Registers a new user with AWS Cognito.

**Input:**
- `email` (String): User's email address
- `password` (String): User's password
- `options` (Dictionary, optional): Additional user attributes

**Output:**
- `Dictionary`: Contains a 'success' key (Boolean) and additional response data if successful

**Description:**
This function registers a new user with AWS Cognito. It can also include additional user attributes if provided in the options dictionary. After sign up, with standard process, users will receive a confirmation code. Confirmation can be send using the `confirm_sign_up` function

### confirm_sign_up

```confirm_sign_up(email: String, confirmation_code: String) -> Dictionary```

Confirms a user's registration using a confirmation code.

**Input:**
- `email` (String): User's email address
- `confirmation_code` (String): Confirmation code sent to the user

**Output:**
- `Dictionary`: Contains a 'success' key (Boolean) and additional response data if successful

**Description:**
This function confirms a user's registration in AWS Cognito using the provided confirmation code.
On success, users will be confirmed and will be able to login.

## API Client

A simple an lightweight abstraction layer on top of HTTPRequest node, with built in authentication handling.

### make_authenticated_request

```make_authenticated_request(endpoint: String, headers: Array, method: HTTPClient.Method, body: String) -> Dictionary```

Makes an authenticated HTTP request to the specified endpoint. User should have successfully logged in before usage.

**Input:**
- `endpoint` (String): The URL to send the request to
- `headers` (Array): An array of HTTP headers
- `method` (HTTPClient.Method): The HTTP method to use
- `body` (String): The request body

**Output:**
- `Dictionary`: A response object containing success status, response body, response code, headers, and result

**Description:**
This function first handles authentication using an auth function. If authentication is successful, it adds the authorization header and proceeds to make the HTTP request using the `make_request` function.

### make_request

```make_request(endpoint: String, headers: Array, method: HTTPClient.Method, body: String) -> Dictionary```

Makes an HTTP request to the specified endpoint.

**Input:**
- `endpoint` (String): The URL to send the request to
- `headers` (Array): An array of HTTP headers
- `method` (HTTPClient.Method): The HTTP method to use
- `body` (String): The request body

**Output:**
- `Dictionary`: A response object containing success status, response body, response code, headers, and result

**Description:**
This function creates an HTTPRequest node, sends the request, and processes the response. It handles JSON parsing of the response body and generates a standardized response object using the `generate_response_json` function.

## Data

Simple API to communicate with the AWS Amplify backend persistance data layer, providing functionalities for making GraphQL queries and mutations.

### mutate

```mutate(query: String, operation_name: String) -> Dictionary```

Performs a GraphQL mutation operation.

**Input:**
- `query` (String): The GraphQL mutation query
- `operation_name` (String): The name of the mutation operation

**Output:**
- `Dictionary`: A response object from the `make_authenticated_request` function, containing:
  - `success` (Boolean): Indicates if the request was successful
  - `response_body` (Variant): The response body
  - `response_code` (int): The HTTP response code
  - `response_headers` (Array): The response headers
  - `result` (int): The result code from the HTTPRequest

**Description:**
This function constructs a GraphQL mutation request and sends it to the specified endpoint using the `make_authenticated_request` function. It formats the query with the provided operation name and sends it as a POST request.

### query

```query(query: String, operation_name: String) -> Dictionary```

Performs a GraphQL query operation.

**Input:**
- `query` (String): The GraphQL query
- `operation_name` (String): The name of the query operation

**Output:**
- `Dictionary`: A response object from the `make_authenticated_request` function, containing:
  - `success` (Boolean): Indicates if the request was successful
  - `response_body` (Variant): The response body
  - `response_code` (int): The HTTP response code
  - `response_headers` (Array): The response headers
  - `result` (int): The result code from the HTTPRequest

**Description:**
This function constructs a GraphQL query request and sends it to the specified endpoint using the `make_authenticated_request` function. It formats the query with the provided operation name and sends it as a POST request.

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