extends Node
# MigrationTool - Migra dados de JSON para SQLite
# Como usar: Adicione este script a uma cena e execute

const JSON_PLAYERS_PATH = "user://players_database.json"
const JSON_SESSIONS_PATH = "user://active_sessions.json"

var migration_log: Array = []
var players_migrated: int = 0
var sessions_migrated: int = 0

signal migration_started()
signal migration_progress(current: int, total: int, message: String)
signal migration_completed(success: bool, log: Array)

func _ready():
	print("\n" + "="*60)
	print("MIGRATION TOOL - JSON to SQLite")
	print("="*60 + "\n")

func start_migration() -> Dictionary:
	# Inicia o processo de migracao
	migration_log.clear()
	players_migrated = 0
	sessions_migrated = 0
	
	migration_started.emit()
	_log("Iniciando migracao de dados...")
	
	# Verificar se o DatabaseManager esta pronto
	if not DatabaseManager or not DatabaseManager.db_ready:
		_log("[ERRO] DatabaseManager nao esta pronto! Verifique se o SQLite esta ativo.", true)
		migration_completed.emit(false, migration_log)
		return {"success": false, "error": "DatabaseManager not ready"}
	
	_log("[OK] DatabaseManager pronto")
	
	# Verificar se arquivos JSON existem
	if not FileAccess.file_exists(JSON_PLAYERS_PATH):
		_log("[AVISO] Arquivo de jogadores nao encontrado: " + JSON_PLAYERS_PATH)
		_log("Caminho: " + ProjectSettings.globalize_path(JSON_PLAYERS_PATH))
		migration_completed.emit(false, migration_log)
		return {"success": false, "error": "JSON files not found"}
	
	_log("[OK] Arquivos JSON encontrados")
	
	# Migrar jogadores
	var players_result = _migrate_players()
	if not players_result.success:
		_log("[ERRO] Falha ao migrar jogadores", true)
		migration_completed.emit(false, migration_log)
		return players_result
	
	# Migrar sessoes (opcional, pois podem estar vazias)
	_migrate_sessions()
	
	# Resumo
	_log("\n" + "="*60)
	_log("MIGRACAO CONCLUIDA!")
	_log("="*60)
	_log("Jogadores migrados: " + str(players_migrated))
	_log("Sessoes migradas: " + str(sessions_migrated))
	_log("="*60 + "\n")
	
	migration_completed.emit(true, migration_log)
	
	return {
		"success": true,
		"players": players_migrated,
		"sessions": sessions_migrated,
		"log": migration_log
	}

func _migrate_players() -> Dictionary:
	# Migra dados dos jogadores
	_log("\n[1/2] Migrando jogadores...")
	
	# Ler arquivo JSON
	var file = FileAccess.open(JSON_PLAYERS_PATH, FileAccess.READ)
	if not file:
		_log("[ERRO] Nao foi possivel abrir arquivo de jogadores", true)
		return {"success": false, "error": "Cannot open players file"}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		_log("[ERRO] JSON invalido: " + json.get_error_message(), true)
		return {"success": false, "error": "Invalid JSON"}
	
	var players_data = json.data
	if typeof(players_data) != TYPE_DICTIONARY:
		_log("[ERRO] Formato de dados invalido", true)
		return {"success": false, "error": "Invalid data format"}
	
	_log("Jogadores encontrados: " + str(players_data.size()))
	
	var current = 0
	var total = players_data.size()
	
	for username in players_data.keys():
		current += 1
		var player = players_data[username]
		
		migration_progress.emit(current, total, "Migrando: " + username)
		
		# Verificar se ja existe no SQLite
		if DatabaseManager.player_exists(username):
			_log("[SKIP] Jogador ja existe: " + username)
			continue
		
		# Criar jogador no SQLite
		var success = DatabaseManager.create_player(
			username,
			player.get("password_hash", ""),
			player.get("email", "")
		)
		
		if not success:
			_log("[ERRO] Falha ao criar jogador: " + username, true)
			continue
		
		# Atualizar dados adicionais
		var update_data = {
			"created_at": player.get("created_at", ""),
			"last_login": player.get("last_login", ""),
			"level": player.get("level", 1),
			"xp": player.get("xp", 0),
			"kills": player.get("kills", 0),
			"deaths": player.get("deaths", 0),
			"wins": player.get("wins", 0),
			"losses": player.get("losses", 0),
			"matches_played": player.get("matches_played", 0),
			"current_class": player.get("current_class", "villager")
		}
		
		# Tratar posicao (pode estar como Vector3 ou Dictionary)
		var last_position = player.get("last_position", Vector3.ZERO)
		if last_position is Dictionary:
			update_data["last_position_x"] = last_position.get("x", 0)
			update_data["last_position_y"] = last_position.get("y", 0)
			update_data["last_position_z"] = last_position.get("z", 0)
		elif last_position is Vector3:
			update_data["last_position_x"] = last_position.x
			update_data["last_position_y"] = last_position.y
			update_data["last_position_z"] = last_position.z
		
		DatabaseManager.update_player(username, update_data)
		
		players_migrated += 1
		_log("[OK] Migrado: " + username + " (Level " + str(update_data.level) + ", XP " + str(update_data.xp) + ")")
	
	_log("\n[OK] Jogadores migrados: " + str(players_migrated) + "/" + str(total))
	return {"success": true}

func _migrate_sessions() -> Dictionary:
	# Migra sessoes ativas (opcional)
	_log("\n[2/2] Migrando sessoes ativas...")
	
	if not FileAccess.file_exists(JSON_SESSIONS_PATH):
		_log("[INFO] Arquivo de sessoes nao encontrado (normal se nao houver sessoes ativas)")
		return {"success": true}
	
	var file = FileAccess.open(JSON_SESSIONS_PATH, FileAccess.READ)
	if not file:
		_log("[AVISO] Nao foi possivel abrir arquivo de sessoes")
		return {"success": true}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		_log("[AVISO] JSON de sessoes invalido")
		return {"success": true}
	
	var sessions_data = json.data
	if typeof(sessions_data) != TYPE_DICTIONARY:
		return {"success": true}
	
	_log("Sessoes encontradas: " + str(sessions_data.size()))
	
	# Limpar sessoes antigas primeiro
	DatabaseManager.clear_all_sessions()
	
	for username in sessions_data.keys():
		var peer_id = sessions_data[username]
		
		# Verificar se o jogador existe
		if not DatabaseManager.player_exists(username):
			_log("[SKIP] Sessao ignorada (jogador nao existe): " + username)
			continue
		
		# Nota: Normalmente nao migramos sessoes ativas, pois sao temporarias
		# Mas se quiser, descomente abaixo:
		# DatabaseManager.create_session(username, peer_id)
		# sessions_migrated += 1
		
		_log("[INFO] Sessao encontrada: " + username + " (nao migrada - sessoes sao temporarias)")
	
	_log("[OK] Processo de sessoes concluido")
	return {"success": true}

func _log(message: String, is_error: bool = false):
	# Adiciona mensagem ao log
	var prefix = "[ERROR] " if is_error else ""
	var full_message = prefix + message
	migration_log.append(full_message)
	
	if is_error:
		push_error(full_message)
	else:
		print(full_message)

func print_summary():
	# Imprime resumo da migracao
	print("\n" + "="*60)
	print("RESUMO DA MIGRACAO")
	print("="*60)
	for line in migration_log:
		print(line)
	print("="*60 + "\n")

# ==================== UTILITY FUNCTIONS ====================

func get_json_paths() -> Dictionary:
	# Retorna os caminhos dos arquivos JSON
	return {
		"players": ProjectSettings.globalize_path(JSON_PLAYERS_PATH),
		"sessions": ProjectSettings.globalize_path(JSON_SESSIONS_PATH)
	}

func backup_json_files() -> bool:
	# Cria backup dos arquivos JSON antes da migracao
	_log("\nCriando backup dos arquivos JSON...")
	
	var backup_dir = "user://backup_json_" + Time.get_datetime_string_from_system().replace(":", "-")
	DirAccess.make_dir_absolute(backup_dir)
	
	# Backup players
	if FileAccess.file_exists(JSON_PLAYERS_PATH):
		var content = FileAccess.open(JSON_PLAYERS_PATH, FileAccess.READ).get_as_text()
		var backup_file = FileAccess.open(backup_dir + "/players_database.json", FileAccess.WRITE)
		backup_file.store_string(content)
		backup_file.close()
		_log("[OK] Backup criado: players_database.json")
	
	# Backup sessions
	if FileAccess.file_exists(JSON_SESSIONS_PATH):
		var content = FileAccess.open(JSON_SESSIONS_PATH, FileAccess.READ).get_as_text()
		var backup_file = FileAccess.open(backup_dir + "/active_sessions.json", FileAccess.WRITE)
		backup_file.store_string(content)
		backup_file.close()
		_log("[OK] Backup criado: active_sessions.json")
	
	_log("[OK] Backup salvo em: " + ProjectSettings.globalize_path(backup_dir))
	return true

func verify_migration() -> Dictionary:
	# Verifica se a migracao foi bem sucedida
	_log("\nVerificando migracao...")
	
	var json_count = _count_json_players()
	var db_count = _count_db_players()
	
	_log("Jogadores no JSON: " + str(json_count))
	_log("Jogadores no SQLite: " + str(db_count))
	
	var success = db_count >= json_count
	
	if success:
		_log("[OK] Migracao verificada com sucesso!")
	else:
		_log("[AVISO] Numero de jogadores difere", true)
	
	return {
		"success": success,
		"json_count": json_count,
		"db_count": db_count
	}

func _count_json_players() -> int:
	# Conta jogadores no JSON
	if not FileAccess.file_exists(JSON_PLAYERS_PATH):
		return 0
	
	var file = FileAccess.open(JSON_PLAYERS_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) != OK:
		return 0
	
	var data = json.data
	if typeof(data) == TYPE_DICTIONARY:
		return data.size()
	return 0

func _count_db_players() -> int:
	# Conta jogadores no SQLite
	if not DatabaseManager or not DatabaseManager.db_ready:
		return 0
	
	DatabaseManager.db.query("SELECT COUNT(*) as count FROM players")
	var result = DatabaseManager.db.query_result
	
	if result.size() > 0:
		return result[0]["count"]
	return 0

