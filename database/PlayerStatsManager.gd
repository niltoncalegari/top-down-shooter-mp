extends Node
# PlayerStatsManager - Rastreia estatísticas da partida atual

var match_stats: Dictionary = {}  # {peer_id: {kills, deaths, class}}
var match_start_time: float = 0.0
var match_in_progress: bool = false

signal match_started()
signal match_ended(results: Dictionary)
signal player_killed(killer_id: int, victim_id: int)
signal player_died(player_id: int)

func _ready():
	print("[STATS] PlayerStatsManager inicializado")

# ==================== MATCH CONTROL ====================

func start_match() -> void:
	# Inicia uma nova partida
	match_stats.clear()
	match_start_time = Time.get_ticks_msec() / 1000.0
	match_in_progress = true
	print("[GAME] Partida iniciada")
	match_started.emit()

func end_match() -> Dictionary:
	# Finaliza a partida e retorna resultados
	match_in_progress = false
	var duration = (Time.get_ticks_msec() / 1000.0) - match_start_time
	
	var results = {
		"duration": duration,
		"players": match_stats.duplicate(true)
	}
	
	print("[MATCH] Partida finalizada | Duração: %.1f segundos" % duration)
	match_ended.emit(results)
	
	# Salvar stats no banco de dados
	_save_match_results(results)
	
	return results

func _save_match_results(results: Dictionary) -> void:
	# Salva os resultados da partida no banco de dados
	for peer_id in results.players.keys():
		var stats = results.players[peer_id]
		var username = stats.get("username", "")
		
		if username == "":
			continue
		
		# Determinar se venceu (simplificado: quem tem mais kills)
		var won = _did_player_win(peer_id, results.players)
		
		DatabaseManager.add_match_stats(
			username,
			won,
			stats.get("kills", 0),
			stats.get("deaths", 0)
		)
		
		# Salvar classe atual
		DatabaseManager.save_player_class(username, stats.get("class", "villager"))
		
		print("[SAVE] Stats salvas para ", username, " | Kills: ", stats.kills, " Deaths: ", stats.deaths)

func _did_player_win(peer_id: int, all_players: Dictionary) -> bool:
	# Determina se o jogador venceu (simplificado: mais kills)
	var player_kills = all_players[peer_id].get("kills", 0)
	var max_kills = 0
	
	for pid in all_players.keys():
		max_kills = max(max_kills, all_players[pid].get("kills", 0))
	
	return player_kills == max_kills and max_kills > 0

# ==================== PLAYER TRACKING ====================

func register_player(peer_id: int, username: String, player_class: String = "villager") -> void:
	# Registra um jogador na partida
	match_stats[peer_id] = {
		"username": username,
		"peer_id": peer_id,
		"class": player_class,
		"kills": 0,
		"deaths": 0,
		"damage_dealt": 0,
		"damage_taken": 0
	}
	print("[STATS] Jogador registrado: ", username, " (", peer_id, ")")

func unregister_player(peer_id: int) -> void:
	# Remove um jogador da partida
	if match_stats.has(peer_id):
		var username = match_stats[peer_id].username
		match_stats.erase(peer_id)
		print("[STATS] Jogador removido: ", username)

func update_player_class(peer_id: int, player_class: String) -> void:
	# Atualiza a classe do jogador
	if match_stats.has(peer_id):
		match_stats[peer_id]["class"] = player_class
		print("[STATS] Classe atualizada para ", match_stats[peer_id].username, ": ", player_class)

# ==================== EVENTS ====================

func record_kill(killer_id: int, victim_id: int) -> void:
	# Registra uma kill
	if not match_in_progress:
		return
	
	if match_stats.has(killer_id):
		match_stats[killer_id]["kills"] += 1
		print(" ", match_stats[killer_id].username, " matou ", match_stats.get(victim_id, {}).get("username", "?"))
	
	if match_stats.has(victim_id):
		match_stats[victim_id]["deaths"] += 1
	
	player_killed.emit(killer_id, victim_id)

func record_death(player_id: int) -> void:
	# Registra uma morte (sem killer conhecido)
	if not match_in_progress:
		return
	
	if match_stats.has(player_id):
		match_stats[player_id]["deaths"] += 1
		print(" ", match_stats[player_id].username, " morreu")
	
	player_died.emit(player_id)

func record_damage(attacker_id: int, victim_id: int, amount: float) -> void:
	# Registra dano causado/recebido
	if not match_in_progress:
		return
	
	if match_stats.has(attacker_id):
		match_stats[attacker_id]["damage_dealt"] += amount
	
	if match_stats.has(victim_id):
		match_stats[victim_id]["damage_taken"] += amount

# ==================== QUERIES ====================

func get_player_stats(peer_id: int) -> Dictionary:
	# Retorna as stats de um jogador na partida atual
	return match_stats.get(peer_id, {})

func get_all_stats() -> Dictionary:
	# Retorna todas as stats da partida
	return match_stats.duplicate(true)

func get_leaderboard() -> Array:
	# Retorna ranking da partida atual por kills
	var players = []
	for peer_id in match_stats.keys():
		players.append(match_stats[peer_id])
	
	players.sort_custom(func(a, b): return a.kills > b.kills)
	return players

func print_stats() -> void:
	# Imprime as stats atuais (debug)
	print("\n=== STATS DA PARTIDA ===")
	for peer_id in match_stats.keys():
		var stats = match_stats[peer_id]
		print("%s (%d) | Kills: %d | Deaths: %d | Classe: %s" % [
			stats.username,
			peer_id,
			stats.kills,
			stats.deaths,
			stats["class"]
		])
	print("========================\n")

