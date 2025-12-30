extends Node
# DatabaseManager - Gerencia persistência de dados dos jogadores
# Usa arquivos JSON por simplicidade (pode ser migrado para SQLite depois)

const DATABASE_PATH = "user://players_database.json"
const SESSIONS_PATH = "user://active_sessions.json"

var players_data: Dictionary = {}
var active_sessions: Dictionary = {}  # {username: peer_id}

signal data_loaded()
signal data_saved()

func _ready():
	print("[DB] DatabaseManager inicializado")
	load_database()
	load_sessions()

# ==================== LOAD/SAVE ====================

func load_database() -> void:
	if not FileAccess.file_exists(DATABASE_PATH):
		print("[DB] Banco de dados nao existe. Criando novo...")
		players_data = {}
		save_database()
		return
	
	var file = FileAccess.open(DATABASE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		
		if error == OK:
			players_data = json.data
			print("[DB] Banco de dados carregado: ", players_data.size(), " jogadores")
			data_loaded.emit()
		else:
			print("[DB] Erro ao parsear JSON: ", json.get_error_message())
			players_data = {}
	else:
		print("[DB] Erro ao abrir arquivo de banco de dados")
		players_data = {}

func save_database() -> void:
	var file = FileAccess.open(DATABASE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(players_data, "\t")
		file.store_string(json_string)
		file.close()
		print("[DB] Banco de dados salvo")
		data_saved.emit()
	else:
		print("[DB] Erro ao salvar banco de dados")

func load_sessions() -> void:
	if not FileAccess.file_exists(SESSIONS_PATH):
		active_sessions = {}
		save_sessions()
		return
	
	var file = FileAccess.open(SESSIONS_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		
		if error == OK:
			active_sessions = json.data
			print("[DB] Sessoes ativas carregadas: ", active_sessions.size())
		else:
			active_sessions = {}
	else:
		active_sessions = {}

func save_sessions() -> void:
	var file = FileAccess.open(SESSIONS_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(active_sessions, "\t")
		file.store_string(json_string)
		file.close()

# ==================== PLAYER CRUD ====================

func create_player(username: String, password_hash: String, email: String = "") -> bool:
	# Cria um novo jogador no banco de dados
	if players_data.has(username):
		print("[DB] Usuario ja existe: ", username)
		return false
	
	players_data[username] = {
		"username": username,
		"password_hash": password_hash,
		"email": email,
		"created_at": Time.get_datetime_string_from_system(),
		"last_login": "",
		"level": 1,
		"xp": 0,
		"kills": 0,
		"deaths": 0,
		"wins": 0,
		"losses": 0,
		"matches_played": 0,
		# Dados de gameplay
		"current_class": "villager",  # Classe atual do jogador
		"last_position": Vector3.ZERO,  # Última posição salva
		"inventory": [],  # Inventário (para futuro)
		"equipped_items": {}  # Itens equipados (para futuro)
	}
	
	save_database()
	print("[DB] Jogador criado: ", username)
	return true

func get_player(username: String) -> Dictionary:
	# Retorna os dados de um jogador
	return players_data.get(username, {})

func player_exists(username: String) -> bool:
	# Verifica se um jogador existe
	return players_data.has(username)

func update_player(username: String, data: Dictionary) -> bool:
	# Atualiza dados de um jogador
	if not players_data.has(username):
		print("[DB] Jogador nao existe: ", username)
		return false
	
	for key in data:
		players_data[username][key] = data[key]
	
	save_database()
	print("[DB] Jogador atualizado: ", username)
	return true

func update_last_login(username: String) -> void:
	# Atualiza o último login do jogador
	if players_data.has(username):
		players_data[username]["last_login"] = Time.get_datetime_string_from_system()
		save_database()

# ==================== SESSION MANAGEMENT ====================

func create_session(username: String, peer_id: int) -> bool:
	# Cria uma sessão ativa para um jogador
	if is_user_logged_in(username):
		print("[DB] Usuario ja esta logado: ", username)
		return false
	
	active_sessions[username] = peer_id
	save_sessions()
	print("[DB] Sessao criada: ", username, " | Peer: ", peer_id)
	return true

func remove_session(username: String) -> void:
	# Remove a sessão ativa de um jogador
	if active_sessions.has(username):
		active_sessions.erase(username)
		save_sessions()
		print("[DB] Sessao removida: ", username)

func remove_session_by_peer(peer_id: int) -> void:
	# Remove a sessão ativa por peer_id
	for username in active_sessions.keys():
		if active_sessions[username] == peer_id:
			remove_session(username)
			break

func is_user_logged_in(username: String) -> bool:
	# Verifica se um usuário está logado
	return active_sessions.has(username)

func get_logged_users() -> Array:
	# Retorna lista de usuários logados
	return active_sessions.keys()

func clear_all_sessions() -> void:
	# Limpa todas as sessões (útil ao fechar o servidor)
	active_sessions = {}
	save_sessions()
	print("[DB] Todas as sessoes foram limpas")

# ==================== STATS ====================

func add_match_stats(username: String, won: bool, kills: int, deaths: int) -> void:
	# Adiciona estatísticas de uma partida
	if not players_data.has(username):
		return
	
	var player = players_data[username]
	player["matches_played"] += 1
	player["kills"] += kills
	player["deaths"] += deaths
	
	if won:
		player["wins"] += 1
		player["xp"] += 100  # XP por vitória
	else:
		player["losses"] += 1
		player["xp"] += 25   # XP por derrota
	
	# Sistema simples de level (a cada 500 XP sobe 1 nível)
	player["level"] = int(player["xp"] / 500) + 1
	
	save_database()
	print("[DB] Stats atualizadas para ", username)

func get_ranking(limit: int = 10) -> Array:
	# Retorna ranking dos melhores jogadores
	var players_array = []
	
	for username in players_data.keys():
		var player = players_data[username]
		players_array.append({
			"username": username,
			"level": player.get("level", 1),
			"xp": player.get("xp", 0),
			"wins": player.get("wins", 0),
			"kd_ratio": float(player.get("kills", 0)) / max(1, player.get("deaths", 1))
		})
	
	# Ordenar por XP
	players_array.sort_custom(func(a, b): return a.xp > b.xp)
	
	# Retornar apenas o limite
	if players_array.size() > limit:
		players_array = players_array.slice(0, limit)
	
	return players_array

# ==================== GAMEPLAY DATA ====================

func save_player_class(username: String, player_class: String) -> void:
	# Salva a classe atual do jogador
	if not players_data.has(username):
		return
	
	players_data[username]["current_class"] = player_class
	save_database()
	print("[DB] Classe salva para ", username, ": ", player_class)

func get_player_class(username: String) -> String:
	# Retorna a classe atual do jogador
	if not players_data.has(username):
		return "villager"
	
	return players_data[username].get("current_class", "villager")

func save_player_position(username: String, position: Vector3) -> void:
	# Salva a posição do jogador
	if not players_data.has(username):
		return
	
	players_data[username]["last_position"] = {
		"x": position.x,
		"y": position.y,
		"z": position.z
	}
	save_database()

func get_player_position(username: String) -> Vector3:
	# Retorna a última posição salva do jogador
	if not players_data.has(username):
		return Vector3.ZERO
	
	var pos_dict = players_data[username].get("last_position", {"x": 0, "y": 0, "z": 0})
	if pos_dict is Dictionary:
		return Vector3(pos_dict.get("x", 0), pos_dict.get("y", 0), pos_dict.get("z", 0))
	return Vector3.ZERO

func get_player_full_data(username: String) -> Dictionary:
	# Retorna todos os dados do jogador incluindo gameplay
	if not players_data.has(username):
		return {}
	
	return players_data[username].duplicate(true)
