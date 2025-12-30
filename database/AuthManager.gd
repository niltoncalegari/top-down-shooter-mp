extends Node
# AuthManager - Gerencia autenticacao e autorizacao de jogadores

signal login_success(username: String)
signal login_failed(error_message: String)
signal register_success(username: String)
signal register_failed(error_message: String)

var current_user: String = ""
var current_peer_id: int = 0

func _ready():
	print("[AUTH] AuthManager inicializado")

# ==================== PASSWORD HASHING ====================

func hash_password(password: String) -> String:
	# Hash de senha usando SHA256
	# NOTA: Para producao, considere usar bcrypt ou argon2
	return password.sha256_text()

func verify_password(password: String, password_hash: String) -> bool:
	# Verifica se a senha corresponde ao hash
	return hash_password(password) == password_hash

# ==================== VALIDATION ====================

func validate_username(username: String) -> Dictionary:
	# Valida o nome de usuario
	var result = {"valid": true, "error": ""}
	
	if username.length() < 3:
		result["valid"] = false
		result["error"] = "Nome de usuário deve ter pelo menos 3 caracteres"
		return result
	
	if username.length() > 20:
		result["valid"] = false
		result["error"] = "Nome de usuário deve ter no máximo 20 caracteres"
		return result
	
	# Verificar se contém apenas caracteres válidos (letras, números, underscore)
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9_]+$")
	if not regex.search(username):
		result["valid"] = false
		result["error"] = "Nome de usuário deve conter apenas letras, números e _"
		return result
	
	return result

func validate_password(password: String) -> Dictionary:
	# Valida a senha
	var result = {"valid": true, "error": ""}
	
	if password.length() < 6:
		result["valid"] = false
		result["error"] = "Senha deve ter pelo menos 6 caracteres"
		return result
	
	if password.length() > 50:
		result["valid"] = false
		result["error"] = "Senha deve ter no máximo 50 caracteres"
		return result
	
	return result

func validate_email(email: String) -> Dictionary:
	# Valida o email (opcional)
	var result = {"valid": true, "error": ""}
	
	if email == "":
		return result  # Email é opcional
	
	# Regex simples para email
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	if not regex.search(email):
		result["valid"] = false
		result["error"] = "Email inválido"
		return result
	
	return result

# ==================== REGISTER ====================

func register(username: String, password: String, email: String = "") -> void:
	# Registra um novo jogador
	print("[AUTH] Tentando registrar: ", username)
	
	# Validar username
	var username_validation = validate_username(username)
	if not username_validation["valid"]:
		print("[AUTH] Registro falhou: ", username_validation["error"])
		register_failed.emit(username_validation["error"])
		return
	
	# Validar password
	var password_validation = validate_password(password)
	if not password_validation["valid"]:
		print("[AUTH] Registro falhou: ", password_validation["error"])
		register_failed.emit(password_validation["error"])
		return
	
	# Validar email (se fornecido)
	var email_validation = validate_email(email)
	if not email_validation["valid"]:
		print("[AUTH] Registro falhou: ", email_validation["error"])
		register_failed.emit(email_validation["error"])
		return
	
	# Verificar se usuário já existe
	if DatabaseManager.player_exists(username):
		print("[AUTH] Registro falhou: Usuario ja existe")
		register_failed.emit("Nome de usuário já está em uso")
		return
	
	# Criar jogador
	var password_hash = hash_password(password)
	var success = DatabaseManager.create_player(username, password_hash, email)
	
	if success:
		print("[AUTH] Registro bem-sucedido: ", username)
		register_success.emit(username)
	else:
		print("[AUTH] Registro falhou: Erro ao criar jogador")
		register_failed.emit("Erro ao criar jogador. Tente novamente.")

# ==================== LOGIN ====================

func login(username: String, password: String, peer_id: int = 0) -> void:
	# Faz login de um jogador
	print("[AUTH] Tentando fazer login: ", username)
	
	# Verificar se usuário existe
	if not DatabaseManager.player_exists(username):
		print("[AUTH] Login falhou: Usuario nao existe")
		login_failed.emit("Usuário ou senha incorretos")
		return
	
	# Verificar se já está logado
	if DatabaseManager.is_user_logged_in(username):
		print("[AUTH] Login falhou: Usuario ja esta logado")
		login_failed.emit("Usuário já está logado em outra sessão")
		return
	
	# Verificar senha
	var player_data = DatabaseManager.get_player(username)
	if not verify_password(password, player_data["password_hash"]):
		print("[AUTH] Login falhou: Senha incorreta")
		login_failed.emit("Usuário ou senha incorretos")
		return
	
	# Criar sessão
	var session_created = DatabaseManager.create_session(username, peer_id)
	if not session_created:
		print("[AUTH] Login falhou: Erro ao criar sessao")
		login_failed.emit("Erro ao criar sessão. Tente novamente.")
		return
	
	# Atualizar último login
	DatabaseManager.update_last_login(username)
	
	# Salvar usuário atual
	current_user = username
	current_peer_id = peer_id
	
	print("[AUTH] Login bem-sucedido: ", username, " | Peer: ", peer_id)
	login_success.emit(username)

# ==================== LOGOUT ====================

func logout(username: String = "") -> void:
	# Faz logout de um jogador
	var user_to_logout = username if username != "" else current_user
	
	if user_to_logout == "":
		print("[AUTH] Nenhum usuario para fazer logout")
		return
	
	DatabaseManager.remove_session(user_to_logout)
	
	if user_to_logout == current_user:
		current_user = ""
		current_peer_id = 0
	
	print("[AUTH] Logout bem-sucedido: ", user_to_logout)

func logout_by_peer(peer_id: int) -> void:
	# Faz logout por peer_id (quando desconecta)
	DatabaseManager.remove_session_by_peer(peer_id)
	
	if peer_id == current_peer_id:
		current_user = ""
		current_peer_id = 0
	
	print("[AUTH] Logout por peer: ", peer_id)

# ==================== GETTERS ====================

func is_logged_in() -> bool:
	# Verifica se ha um usuario logado localmente
	return current_user != ""

func get_current_user() -> String:
	# Retorna o usuario atual
	return current_user

func get_current_peer_id() -> int:
	# Retorna o peer_id atual
	return current_peer_id

func get_user_data(username: String = "") -> Dictionary:
	# Retorna os dados do usuario (atual ou especificado)
	var user = username if username != "" else current_user
	return DatabaseManager.get_player(user)

