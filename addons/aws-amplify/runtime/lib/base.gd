class_name AWSAmplifyBase
extends Node

class HEADERS:
	const CONTENT_TYPE_APPLICATION_X_AMZ_JSON_1_1 = "Content-Type: application/x-amz-json-1.1"
	static func X_AMZ_TARGET(target) -> String:
		return "X-Amz-Target: AWSCognitoIdentityProviderService." + target
	static func AUTHORIZATION_BEARER(access_token) -> String:
		return "Authorization: Bearer " + access_token

class BODY:
	const CLIENT_ID = "ClientId"
	const AUTH_FLOW = "AuthFlow"
	const AUTH_PARAMETERS = "AuthParameters"
	const USERNAME = "Username"
	const PASSWORD = "Password"
	const CONFIRMATION_CODE = "ConfirmationCode"
	const USER_ATTRIBUTES = "UserAttributes"
	const AUTHENTICATED_RESULT = "AuthenticationResult"
	const ACCESS_TOKEN = "AccessToken"
	const REFRESH_TOKEN = "RefreshToken"

class USER_ATTRIBUTES:
	const NAME = "name"
	const FAMILY_NAME = "family_name"
	const GIVEN_NAME = "given_name"	
	const MIDDLE_NAME = "middle_name"
	const NICKNAME = "nickname"
	const PREFERRED_NAME = "preferred_username"
	const PROFILE = "profile"
	const PICTURE = "picture"
	const WEBSITE = "website"
	const GENDER = "gender"
	const BIRTHDATE = "birthdate"
	const ZONEINFO = "zoneinfo"
	const LOCALE = "locale"
	const UPDATED_AT = "updated_at"
	const ADDRESS = "address"
	const EMAIL = "email"
	const PHONE_NUMBER = "phone_number"
	const SUB = "sub"

enum AuthMode {
	EMAIL,
	PHONENUMBER
}
