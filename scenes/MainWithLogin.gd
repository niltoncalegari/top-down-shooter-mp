extends Node

@onready var login_screen = $LoginScreen

func _ready():
	print("🎮 MainWithLogin iniciado")
	
	# Conectar sinal de login
	if login_screen:
		login_screen.login_completed.connect(_on_login_completed)
		login_screen.show()
	else:
		push_error("❌ LoginScreen não encontrado!")
	
	# Se já estiver logado (debug), pular para o menu
	if AuthManager.is_logged_in():
		print("ℹ️ Usuário já logado: ", AuthManager.get_current_user())
		_on_login_completed(AuthManager.get_current_user())

func _on_login_completed(username: String):
	print("✅ Login completo: ", username)
	
	# Esconder tela de login
	if login_screen:
		login_screen.hide()
	
	# Aguardar um frame antes de carregar o menu
	await get_tree().process_frame
	
	# Carregar a cena de teste multiplayer
	print("🔄 Carregando cena principal...")
	get_tree().change_scene_to_file("res://scenes/main.tscn")
