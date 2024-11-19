extends Control
class_name AuthForm

const USER_CONFIG_PATH = "user://.config"
const CONFIG_EMAIL = "email"

var amplify: AWSAmplify = aws_amplify
var config: Dictionary = {}

# Form

@onready var auth_tab: TabContainer = %AuthTab
@onready var sign_in: VBoxContainer = %SignIn
@onready var sign_up: VBoxContainer = %SignUp

# Sign-In

@onready var sign_in_e_mail: LineEdit = %SignInEMail
@onready var sign_in_password: AuthPassword = %SignInPasswordContainer
@onready var sign_in_button: Button = %SignInButton
@onready var sign_in_message: AuthMessage = %SignInMessage
@onready var sign_in_remember_me: CheckButton = %SignInRememberMe
@onready var forgot_password_confirm: VBoxContainer = %ForgotPasswordConfirm
@onready var forgot_password_confirm_code: LineEdit = %ForgotPasswordConfirmCode
@onready var forgot_password_confirm_password: AuthPassword = %ForgotPasswordConfirmPasswordContainer
@onready var forgot_password_confirm_password_confirmation: AuthPassword = %ForgotPasswordConfirmPasswordConfirmationContainer
@onready var forgot_password_confirm_button: Button = %ForgotPasswordConfirmButton
@onready var forgot_password_confirm_message: AuthMessage = %ForgotPasswordConfirmMessage

func _on_sign_in_input_changed(new_text: String) -> void:
	if (sign_in_e_mail.text != "" and sign_in_password.password.text != ""):
		sign_in_button.disabled = false
	else:
		sign_in_button.disabled = true
		
func _on_sign_in_button_pressed():
	sign_in_button.disabled = true
	
	var response = await amplify.auth.sign_in_with_username_password(sign_in_e_mail.text, sign_in_password.password.text)
	if response.success and sign_in_remember_me.toggled:
		config[CONFIG_EMAIL] = sign_in_e_mail.text
		_save_user_config()
		sign_in_message.set_success_message("You are signed-in!")
	else:
		sign_in_message.set_error_message(response.response_body.message)
		
	sign_in_button.disabled = false
		
func _on_sign_in_sign_up_link_pressed() -> void:
	auth_tab.current_tab = 1

func _on_sign_in_visibility_changed() -> void:
	if sign_in.visible: 
		sign_in_password.password.text = ""
		sign_in_message.text = ""
		sign_in_button.disabled = true

func _on_forgot_password_input_changed(new_text: String) -> void:
	if (forgot_password_confirm_code.text != "" and 
		forgot_password_confirm_password.password.text != "" and 
		forgot_password_confirm_password_confirmation.password.text != ""):
		forgot_password_confirm_button.disabled = false
	else:
		forgot_password_confirm_button.disabled = true
	
func _forgot_password_confirm_link_pressed() -> void:
	var response = await amplify.auth.forgot_password(sign_in_e_mail.text)
	if response.success:
		sign_in.hide()
		forgot_password_confirm.show()
	else:
		sign_in_message.set_error_message(response.response_body.message)

func _forgot_password_confirm_button_pressed() -> void:
	forgot_password_confirm_button.disabled = true
	if forgot_password_confirm_password.password.text != forgot_password_confirm_password_confirmation.password.text:
		forgot_password_confirm_message.set_error_message("Both passwords do not match!")
	else:
		var response = await amplify.auth.forgot_password_confirm_code(
			sign_in_e_mail.text, 
			forgot_password_confirm_code.text, 
			forgot_password_confirm_password.password.text
		)
		if response.success:
			sign_in.show()
			forgot_password_confirm.hide()
		else:
			forgot_password_confirm_message.set_error_message(response.response_body.message)
	forgot_password_confirm_button.disabled = false

func _forgot_password_confirm_send_code_link_pressed() -> void:
	_forgot_password_confirm_link_pressed()

func _on_forgot_password_confirm_visibility_changed() -> void:
	if forgot_password_confirm.visible:
		auth_tab.set_tab_disabled(1, true)
		forgot_password_confirm_code.text = ""
		forgot_password_confirm_password.password.text = ""
		forgot_password_confirm_password_confirmation.password.text = ""
	else:
		auth_tab.set_tab_disabled(1, false)
	
# Sign-Up

@onready var sign_up_e_mail: LineEdit = %SignUpEMail
@onready var sign_up_password: AuthPassword = %SignUpPasswordContainer
@onready var sign_up_password_confirmation: AuthPassword = %SignUpPasswordConfirmationContainer
@onready var sign_up_button: Button = %SignUpButton
@onready var sign_up_message: AuthMessage = %SignUpMessage
@onready var sign_up_confirm: VBoxContainer = %SignUpConfirm
@onready var sign_up_confirm_e_mail: LineEdit = %SignUpConfirmEMail
@onready var sign_up_confirm_code: LineEdit = %SignUpConfirmCode
@onready var sign_up_confirm_button: Button = %SignUpConfirmButton
@onready var sign_up_confirm_message: AuthMessage = %SignUpConfirmMessage

func _on_sign_up_input_changed(new_text: String) -> void:
	if (sign_up_e_mail.text != "" and 
		sign_up_password.password.text != "" and 
		sign_up_password_confirmation.password.text != ""):
		sign_up_button.disabled = false
	else:
		sign_up_button.disabled = true

func _on_sign_up_button_pressed() -> void:
	sign_up_button.disabled = true
	
	var response = await amplify.auth.sign_up(sign_up_e_mail.text, sign_up_password.password.text)
	if response.success:
		sign_up.hide()
		sign_up_confirm.show()
	else:
		sign_up_message.set_error_message(response.response_body.message)
		
	sign_up_button.disabled = false
	
func _on_sign_up_sign_in_link_pressed() -> void:
	auth_tab.current_tab = 0

func _on_sign_up_visibility_changed() -> void:
	if sign_up.visible:
		sign_up_e_mail.text = ""
		sign_up_password.password.text = ""
		sign_up_password_confirmation.password.text = ""
		sign_up_message.text = ""
		sign_up_button.disabled = true
	
func _on_sign_up_confirm_link_pressed() -> void:
	sign_up.hide()
	sign_up_confirm.show()
	
func _on_sign_up_confirm_input_changed(new_text: String) -> void:
	if (sign_up_confirm_e_mail.text != "" and sign_up_confirm_code.text != ""):
		sign_up_confirm_button.disabled = false
	else:
		sign_up_confirm_button.disabled = true
	
func _on_sign_up_confirm_button_pressed() -> void:
	sign_up_confirm_button.disabled = true
	
	if sign_up_password.password.text != sign_up_password_confirmation.password.text:
		sign_up_confirm_message.set_error_message("Both passwords do not match!")
	else:
		var response = await amplify.auth.sign_up_confirm_code(sign_up_e_mail.text, sign_up_confirm_code.text)
		if response.success:
			sign_up.show()
			sign_up_confirm.hide()
			sign_in_e_mail.text = sign_up_confirm_e_mail.text
			auth_tab.current_tab = 0
		else:
			sign_up_confirm_message.set_error_message(response.response_body.message)
			
	sign_up_confirm_button.disabled = true
	
func _on_sign_up_confirm_resend_code_link_pressed() -> void:
	var response = await amplify.auth.sign_up_resend_code(sign_up_confirm_e_mail.text)
	if response.success:
		sign_up_confirm_message.set_success_message("Code re-sent!")
	else:
		sign_up_confirm_message.set_error_message(response.response_body.message)

func _on_sign_up_confirm_visibility_changed() -> void:
	if sign_up_confirm.visible == true:
		auth_tab.set_tab_disabled(0, true)
		if sign_up_e_mail.text == "":
			sign_up_confirm_e_mail.editable = true
		else:
			sign_up_confirm_e_mail.editable = false
			sign_up_confirm_e_mail.text = sign_up_e_mail.text
		sign_up_confirm_code.text = ""
		sign_up_confirm_message.text = ""
	else:
		auth_tab.set_tab_disabled(0, false)
		
func _load_user_config() -> void:
	if FileAccess.file_exists(USER_CONFIG_PATH):
		var config_file = FileAccess.open(USER_CONFIG_PATH, FileAccess.READ)
		var config_content = config_file.get_as_text()
		config = JSON.parse_string(config_content)
	else:
		config = {}

func _save_user_config() -> void:
	var config_file = FileAccess.open(USER_CONFIG_PATH, FileAccess.WRITE)
	var config_content = JSON.stringify(config)
	config_file.store_string(config_content)

# Sign-Out

@onready var sign_out: VBoxContainer = %SignOut
@onready var sign_out_e_mail: LineEdit = %SignOutEMail
@onready var sign_out_button: Button = %SignOutButton
@onready var sign_out_refresh_counter: Label = %SignOutRefreshCounter

func _on_user_signed_in(user_attriutes):
	auth_tab.hide()
	sign_out.show()
	sign_out_e_mail.text = sign_in_e_mail.text

func _on_user_signed_out(user_attriutes):
	auth_tab.show()
	sign_out.hide()

func _on_sign_out_button_pressed() -> void:
	await amplify.auth.global_sign_out()

func _on_sign_out_refresh_link_pressed() -> void:
	await amplify.auth.refresh_user(true, true)

# Ready

func _ready() -> void:
	amplify.auth.user_signed_in.connect(_on_user_signed_in)
	amplify.auth.user_signed_out.connect(_on_user_signed_out)
		
	auth_tab.set_tab_title(0, "Sign-In")
	auth_tab.set_tab_title(1, "Sign-Up")
	
	_load_user_config()
	
	if config.has(CONFIG_EMAIL):
		auth_tab.current_tab = 0
		sign_in_e_mail.text = config[CONFIG_EMAIL]
		sign_in_e_mail.grab_focus()
	else:
		auth_tab.current_tab = 1
		sign_up_e_mail.grab_focus()
		
func _process(delta: float) -> void:
	if sign_out.visible:
		var time_dictionary = Time.get_datetime_dict_from_unix_time(
			amplify._auth.get_user_access_token_expiration_time()-Time.get_unix_time_from_system()
		)
		var time = "%d:%d:%d" % [time_dictionary["hour"], time_dictionary["minute"], time_dictionary["second"]]
		sign_out_refresh_counter.text = time
