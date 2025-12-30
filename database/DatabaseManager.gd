extends Node
# DatabaseManager - Gerencia persistencia de dados com SQLite
# Versao: 2.0 (SQLite)

const DB_PATH = "res://database/db/game.db"
const MIGRATIONS_DIR = "res://database/migrations/"

var db: SQLite = null
var db_ready: bool = false

signal data_loaded()
signal data_saved()
signal migration_completed(migration_name: String)

func _ready():
	print("[DB] Inicializando DatabaseManager com SQLite...")
	_initialize_database()

func _initialize_database() -> void:
	# Criar instancia do SQLite
	db = SQLite.new()
	
	# Abrir/criar banco de dados
	db.path = DB_PATH
	db.verbosity_level = SQLite.VERBOSE
	
	if not db.open_db():
		push_error("[DB] Erro ao abrir banco de dados!")
		return
	
	print("[DB] Banco de dados aberto: ", DB_PATH)
	
	# Aplicar migrations
	_apply_migrations()
	
	db_ready = true
	data_loaded.emit()

func _apply_migrations() -> void:
	print("[DB] Aplicando migrations...")
	
	# Criar tabela de controle de migrations se nao existir
	var create_migrations_table = """
	CREATE TABLE IF NOT EXISTS schema_migrations (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		migration_name TEXT UNIQUE NOT NULL,
		applied_at TEXT NOT NULL
	);
	"""
	db.query(create_migrations_table)
	
	# Ler migrations do diretorio
	var migrations = _get_migration_files()
	
	for migration_file in migrations:
		if not _is_migration_applied(migration_file):
			print("[DB] Aplicando migration: ", migration_file)
			_apply_migration_file(migration_file)
			_mark_migration_as_applied(migration_file)
			migration_completed.emit(migration_file)

func _get_migration_files() -> Array:
	var migrations = []
	var dir = DirAccess.open(MIGRATIONS_DIR)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".sql"):
				migrations.append(file_name)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	migrations.sort()
	return migrations

func _is_migration_applied(migration_name: String) -> bool:
	var query = "SELECT COUNT(*) as count FROM schema_migrations WHERE migration_name = ?"
	db.query_with_bindings(query, [migration_name])
	
	var result = db.query_result
	if result.size() > 0:
		return result[0]["count"] > 0
	return false

func _apply_migration_file(migration_file: String) -> void:
	var file_path = MIGRATIONS_DIR + migration_file
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var sql_content = file.get_as_text()
		file.close()
		
		# Dividir por comandos SQL (separados por ;)
		var statements = sql_content.split(";")
		
		for statement in statements:
			statement = statement.strip_edges()
			if statement.length() > 0 and not statement.begins_with("--"):
				db.query(statement)
		
		print("[DB] Migration aplicada: ", migration_file)
	else:
		push_error("[DB] Erro ao ler migration: ", migration_file)

func _mark_migration_as_applied(migration_name: String) -> void:
	var query = "INSERT INTO schema_migrations (migration_name, applied_at) VALUES (?, datetime('now'))"
	db.query_with_bindings(query, [migration_name])

# ==================== PLAYER CRUD ====================

func create_player(username: String, password_hash: String, email: String = "") -> bool:
	# Cria um novo jogador no banco de dados
	if not db_ready:
		push_error("[DB] Database not ready")
		return false
	
	var query = """
	INSERT INTO players (username, password_hash, email, created_at)
	VALUES (?, ?, ?, datetime('now'))
	"""
	
	db.query_with_bindings(query, [username, password_hash, email])
	
	if db.query_result.size() > 0:
		print("[DB] Jogador criado: ", username)
		data_saved.emit()
		return true
	else:
		print("[DB] Erro ao criar jogador: ", username)
		return false

func get_player(username: String) -> Dictionary:
	# Retorna os dados de um jogador
	if not db_ready:
		return {}
	
	var query = "SELECT * FROM players WHERE username = ?"
	db.query_with_bindings(query, [username])
	
	var result = db.query_result
	if result.size() > 0:
		return result[0]
	return {}

func player_exists(username: String) -> bool:
	# Verifica se um jogador existe
	if not db_ready:
		return false
	
	var query = "SELECT COUNT(*) as count FROM players WHERE username = ?"
	db.query_with_bindings(query, [username])
	
	var result = db.query_result
	if result.size() > 0:
		return result[0]["count"] > 0
	return false

func update_player(username: String, data: Dictionary) -> bool:
	# Atualiza dados de um jogador
	if not db_ready:
		return false
	
	# Construir UPDATE dinamicamente baseado nas chaves do dictionary
	var set_clauses = []
	var values = []
	
	for key in data.keys():
		set_clauses.append(key + " = ?")
		values.append(data[key])
	
	values.append(username)
	
	var query = "UPDATE players SET " + ", ".join(set_clauses) + " WHERE username = ?"
	db.query_with_bindings(query, values)
	
	print("[DB] Jogador atualizado: ", username)
	data_saved.emit()
	return true

func update_last_login(username: String) -> void:
	# Atualiza o ultimo login do jogador
	if not db_ready:
		return
	
	var query = "UPDATE players SET last_login = datetime('now') WHERE username = ?"
	db.query_with_bindings(query, [username])
	data_saved.emit()

# ==================== SESSION MANAGEMENT ====================

func create_session(username: String, peer_id: int) -> bool:
	# Cria uma sessao ativa para um jogador
	if not db_ready:
		return false
	
	# Verificar se ja existe sessao
	if is_user_logged_in(username):
		print("[DB] Usuario ja esta logado: ", username)
		return false
	
	var query = "INSERT INTO active_sessions (username, peer_id, created_at) VALUES (?, ?, datetime('now'))"
	db.query_with_bindings(query, [username, peer_id])
	
	print("[DB] Sessao criada: ", username, " | Peer: ", peer_id)
	return true

func remove_session(username: String) -> void:
	# Remove a sessao ativa de um jogador
	if not db_ready:
		return
	
	var query = "DELETE FROM active_sessions WHERE username = ?"
	db.query_with_bindings(query, [username])
	
	print("[DB] Sessao removida: ", username)

func remove_session_by_peer(peer_id: int) -> void:
	# Remove a sessao ativa por peer_id
	if not db_ready:
		return
	
	var query = "DELETE FROM active_sessions WHERE peer_id = ?"
	db.query_with_bindings(query, [peer_id])

func is_user_logged_in(username: String) -> bool:
	# Verifica se um usuario esta logado
	if not db_ready:
		return false
	
	var query = "SELECT COUNT(*) as count FROM active_sessions WHERE username = ?"
	db.query_with_bindings(query, [username])
	
	var result = db.query_result
	if result.size() > 0:
		return result[0]["count"] > 0
	return false

func get_logged_users() -> Array:
	# Retorna lista de usuarios logados
	if not db_ready:
		return []
	
	var query = "SELECT username FROM active_sessions"
	db.query(query)
	
	var usernames = []
	for row in db.query_result:
		usernames.append(row["username"])
	return usernames

func clear_all_sessions() -> void:
	# Limpa todas as sessoes (util ao fechar o servidor)
	if not db_ready:
		return
	
	db.query("DELETE FROM active_sessions")
	print("[DB] Todas as sessoes foram limpas")

# ==================== STATS ====================

func add_match_stats(username: String, won: bool, kills: int, deaths: int) -> void:
	# Adiciona estatisticas de uma partida
	if not db_ready:
		return
	
	var xp_gain = 100 if won else 25
	
	var query = """
	UPDATE players 
	SET matches_played = matches_played + 1,
	    kills = kills + ?,
	    deaths = deaths + ?,
	    wins = wins + ?,
	    losses = losses + ?,
	    xp = xp + ?,
	    level = (xp + ?) / 500 + 1
	WHERE username = ?
	"""
	
	var win_inc = 1 if won else 0
	var loss_inc = 0 if won else 1
	
	db.query_with_bindings(query, [kills, deaths, win_inc, loss_inc, xp_gain, xp_gain, username])
	
	print("[DB] Stats atualizadas para ", username)
	data_saved.emit()

func save_match_history(username: String, match_data: Dictionary) -> void:
	# Salva historico de partida
	if not db_ready:
		return
	
	var query = """
	INSERT INTO match_history (username, match_date, duration, won, kills, deaths, damage_dealt, damage_taken, class_used)
	VALUES (?, datetime('now'), ?, ?, ?, ?, ?, ?, ?)
	"""
	
	db.query_with_bindings(query, [
		username,
		match_data.get("duration", 0),
		match_data.get("won", false),
		match_data.get("kills", 0),
		match_data.get("deaths", 0),
		match_data.get("damage_dealt", 0),
		match_data.get("damage_taken", 0),
		match_data.get("class", "villager")
	])

func get_ranking(limit: int = 10) -> Array:
	# Retorna ranking dos melhores jogadores
	if not db_ready:
		return []
	
	var query = "SELECT * FROM player_ranking LIMIT ?"
	db.query_with_bindings(query, [limit])
	
	return db.query_result

func get_player_match_history(username: String, limit: int = 10) -> Array:
	# Retorna historico de partidas do jogador
	if not db_ready:
		return []
	
	var query = "SELECT * FROM match_history WHERE username = ? ORDER BY match_date DESC LIMIT ?"
	db.query_with_bindings(query, [username, limit])
	
	return db.query_result

# ==================== GAMEPLAY DATA ====================

func save_player_class(username: String, player_class: String) -> void:
	# Salva a classe atual do jogador
	if not db_ready:
		return
	
	var query = "UPDATE players SET current_class = ? WHERE username = ?"
	db.query_with_bindings(query, [player_class, username])
	
	print("[DB] Classe salva para ", username, ": ", player_class)

func get_player_class(username: String) -> String:
	# Retorna a classe atual do jogador
	var player = get_player(username)
	return player.get("current_class", "villager")

func save_player_position(username: String, position: Vector3) -> void:
	# Salva a posicao do jogador
	if not db_ready:
		return
	
	var query = "UPDATE players SET last_position_x = ?, last_position_y = ?, last_position_z = ? WHERE username = ?"
	db.query_with_bindings(query, [position.x, position.y, position.z, username])

func get_player_position(username: String) -> Vector3:
	# Retorna a ultima posicao salva do jogador
	var player = get_player(username)
	if player.is_empty():
		return Vector3.ZERO
	
	return Vector3(
		player.get("last_position_x", 0),
		player.get("last_position_y", 0),
		player.get("last_position_z", 0)
	)

func get_player_full_data(username: String) -> Dictionary:
	# Retorna todos os dados do jogador incluindo gameplay
	return get_player(username)

func _exit_tree():
	if db:
		db.close_db()
		print("[DB] Banco de dados fechado")
