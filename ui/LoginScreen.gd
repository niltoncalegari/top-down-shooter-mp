extends Control

# Referências aos nós
@onready var tab_container = $VBoxContainer/TabContainer
@onready var login_tab = $VBoxContainer/TabContainer/Login
@onready var register_tab = $VBoxContainer/TabContainer/Cadastro

# Login
@onready var login_username = $VBoxContainer/TabContainer/Login/VBoxContainer/UsernameInput
@onready var login_password = $VBoxContainer/TabContainer/Login/VBoxContainer/PasswordInput
@onready var login_button = $VBoxContainer/TabContainer/Login/VBoxContainer/LoginButton
@onready var login_status = $VBoxContainer/TabContainer/Login/VBoxContainer/StatusLabel

# Register
@onready var register_username = $VBoxContainer/TabContainer/Cadastro/VBoxContainer/UsernameInput
@onready var register_email = $VBoxContainer/TabContainer/Cadastro/VBoxContainer/EmailInput
@onready var register_password = $VBoxContainer/TabContainer/Cadastro/VBoxContainer/PasswordInput
@onready var register_confirm = $VBoxContainer/TabContainer/Cadastro/VBoxContainer/ConfirmPasswordInput
@onready var register_button = $VBoxContainer/TabContainer/Cadastro/VBoxContainer/RegisterButton
@onready var register_status = $VBoxContainer/TabContainer/Cadastro/VBoxContainer/StatusLabel

signal login_completed(username: String)

func _ready():
	# Conectar sinais do AuthManager
	AuthManager.login_success.connect(_on_login_success)
	AuthManager.login_failed.connect(_on_login_failed)
	AuthManager.register_success.connect(_on_register_success)
	AuthManager.register_failed.connect(_on_register_failed)
	
	# Conectar botões
	login_button.pressed.connect(_on_login_pressed)
	register_button.pressed.connect(_on_register_pressed)
	
	# Permitir Enter para fazer login
	login_username.text_submitted.connect(func(_text): _on_login_pressed())
	login_password.text_submitted.connect(func(_text): _on_login_pressed())
	register_confirm.text_submitted.connect(func(_text): _on_register_pressed())
	
	# Limpar campos de senha ao iniciar (caso venha de logout)
	login_password.text = ""
	register_password.text = ""
	register_confirm.text = ""
	
	# Focar no campo de login
	login_username.grab_focus()
	
	print("[UI] LoginScreen inicializado")

# ==================== LOGIN ====================

func _on_login_pressed():
	var username = login_username.text.strip_edges()
	var password = login_password.text
	
	if username == "":
		login_status.text = " Digite seu nome de usuário"
		login_status.modulate = Color.RED
		return
	
	if password == "":
		login_status.text = " Digite sua senha"
		login_status.modulate = Color.RED
		return
	
	login_status.text = " Autenticando..."
	login_status.modulate = Color.YELLOW
	login_button.disabled = true
	
	# Fazer login
	AuthManager.login(username, password, multiplayer.get_unique_id())

func _on_login_success(username: String):
	login_status.text = " Login bem-sucedido! Bem-vindo, " + username
	login_status.modulate = Color.GREEN
	
	# Aguardar um pouco e emitir sinal
	await get_tree().create_timer(0.5).timeout
	login_completed.emit(username)

func _on_login_failed(error_message: String):
	login_status.text = " " + error_message
	login_status.modulate = Color.RED
	login_button.disabled = false
	
	# Limpar senha
	login_password.text = ""

# ==================== REGISTER ====================

func _on_register_pressed():
	var username = register_username.text.strip_edges()
	var email = register_email.text.strip_edges()
	var password = register_password.text
	var confirm = register_confirm.text
	
	if username == "":
		register_status.text = " Digite um nome de usuário"
		register_status.modulate = Color.RED
		return
	
	if password == "":
		register_status.text = " Digite uma senha"
		register_status.modulate = Color.RED
		return
	
	if password != confirm:
		register_status.text = " As senhas não coincidem"
		register_status.modulate = Color.RED
		return
	
	register_status.text = " Criando conta..."
	register_status.modulate = Color.YELLOW
	register_button.disabled = true
	
	# Registrar
	AuthManager.register(username, password, email)

func _on_register_success(username: String):
	register_status.text = " Conta criada! Faça login para continuar."
	register_status.modulate = Color.GREEN
	register_button.disabled = false
	
	# Limpar campos
	register_username.text = ""
	register_email.text = ""
	register_password.text = ""
	register_confirm.text = ""
	
	# Mudar para aba de login após 1 segundo
	await get_tree().create_timer(1.0).timeout
	tab_container.current_tab = 0
	login_username.text = username
	login_password.grab_focus()

func _on_register_failed(error_message: String):
	register_status.text = " " + error_message
	register_status.modulate = Color.RED
	register_button.disabled = false

# ==================== UTILS ====================

func clear_all_fields():
	login_username.text = ""
	login_password.text = ""
	register_username.text = ""
	register_email.text = ""
	register_password.text = ""
	register_confirm.text = ""
	login_status.text = ""
	register_status.text = ""

func focus_login():
	login_username.grab_focus()
