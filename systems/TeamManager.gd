extends Node
# TeamManager - Gerencia times, cores e atribuições de jogadores

enum Team { NEUTRAL, RED, BLUE }

# Cores disponíveis para seleção
const AVAILABLE_COLORS = {
	"red": Color(0.9, 0.2, 0.2),
	"orange": Color(1.0, 0.5, 0.1),
	"pink": Color(1.0, 0.4, 0.6),
	"blue": Color(0.2, 0.5, 0.9),
	"cyan": Color(0.2, 0.8, 0.8),
	"purple": Color(0.6, 0.3, 0.9),
	"green": Color(0.3, 0.8, 0.3),
	"yellow": Color(0.9, 0.9, 0.2),
}

# Cores atuais de cada time
var team_colors: Dictionary = {
	Team.RED: Color(0.9, 0.2, 0.2),
	Team.BLUE: Color(0.2, 0.5, 0.9)
}

# Mapeamento peer_id -> Team
var player_teams: Dictionary = {}

# Lideres de cada time (peer_id)
var team_leaders: Dictionary = {
	Team.RED: -1,
	Team.BLUE: -1
}

# Spawns por time
var team_spawn_points: Dictionary = {
	Team.RED: Vector3(-10, 0, 0),
	Team.BLUE: Vector3(10, 0, 0),
	Team.NEUTRAL: Vector3(0, 0, 0)
}

signal team_assigned(peer_id: int, team: Team)
signal team_color_changed(team: Team, color: Color)
signal team_leader_changed(team: Team, leader_id: int)

func _ready():
	print("[TEAM] TeamManager pronto")

# Atribui um jogador a um time
func assign_team(peer_id: int, team: Team):
	player_teams[peer_id] = team
	team_assigned.emit(peer_id, team)
	print("[TEAM] Jogador ", peer_id, " atribuido ao time ", Team.keys()[team])
	
	# Se for o primeiro jogador do time, vira líder
	if team != Team.NEUTRAL and team_leaders[team] == -1:
		set_team_leader(team, peer_id)

# Remove jogador do sistema (logout/disconnect)
func remove_player(peer_id: int):
	var team = player_teams.get(peer_id, Team.NEUTRAL)
	player_teams.erase(peer_id)
	
	# Se era líder, transferir liderança
	if team != Team.NEUTRAL and team_leaders[team] == peer_id:
		_transfer_leadership(team)

# Transfere liderança para outro jogador do time
func _transfer_leadership(team: Team):
	for peer_id in player_teams:
		if player_teams[peer_id] == team:
			set_team_leader(team, peer_id)
			return
	
	# Nenhum jogador restante no time
	team_leaders[team] = -1

# Define líder do time
func set_team_leader(team: Team, peer_id: int):
	if team == Team.NEUTRAL:
		return
	
	team_leaders[team] = peer_id
	team_leader_changed.emit(team, peer_id)
	print("[TEAM] Novo lider do time ", Team.keys()[team], ": ", peer_id)

# Retorna o time de um jogador
func get_player_team(peer_id: int) -> Team:
	return player_teams.get(peer_id, Team.NEUTRAL)

# Verifica se jogador é líder do seu time
func is_team_leader(peer_id: int) -> bool:
	var team = get_player_team(peer_id)
	if team == Team.NEUTRAL:
		return false
	return team_leaders[team] == peer_id

# Define cor de um time (apenas líder pode fazer)
func set_team_color(team: Team, color: Color, requester_id: int = -1):
	if team == Team.NEUTRAL:
		return
	
	# Verificar se é o líder
	if requester_id != -1 and not is_team_leader(requester_id):
		print("[TEAM] Jogador ", requester_id, " nao e lider, nao pode mudar cor")
		return
	
	# Verificar se a cor já está sendo usada pelo outro time
	for other_team in [Team.RED, Team.BLUE]:
		if other_team != team and team_colors[other_team].is_equal_approx(color):
			print("[TEAM] Cor ja esta sendo usada por outro time")
			return
	
	team_colors[team] = color
	team_color_changed.emit(team, color)
	print("[TEAM] Cor do time ", Team.keys()[team], " alterada")
	
	# Sincronizar com todos os clientes
	if multiplayer.is_server():
		rpc_sync_team_colors.rpc(team_colors[Team.RED], team_colors[Team.BLUE])

# Retorna cor do time
func get_team_color(team: Team) -> Color:
	return team_colors.get(team, Color.WHITE)

# Retorna cor de um jogador baseado no seu time
func get_player_color(peer_id: int) -> Color:
	var team = get_player_team(peer_id)
	return get_team_color(team)

# Retorna ponto de spawn do time
func get_team_spawn(team: Team) -> Vector3:
	return team_spawn_points.get(team, Vector3.ZERO)

# Define pontos de spawn personalizados
func set_team_spawn(team: Team, position: Vector3):
	team_spawn_points[team] = position
	print("[TEAM] Spawn do time ", Team.keys()[team], " definido em ", position)

# Verifica se dois jogadores são do mesmo time
func are_teammates(peer_id_1: int, peer_id_2: int) -> bool:
	var team1 = get_player_team(peer_id_1)
	var team2 = get_player_team(peer_id_2)
	
	if team1 == Team.NEUTRAL or team2 == Team.NEUTRAL:
		return false
	
	return team1 == team2

# Verifica se dois jogadores são inimigos
func are_enemies(peer_id_1: int, peer_id_2: int) -> bool:
	var team1 = get_player_team(peer_id_1)
	var team2 = get_player_team(peer_id_2)
	
	if team1 == Team.NEUTRAL or team2 == Team.NEUTRAL:
		return false
	
	return team1 != team2

# Retorna lista de jogadores de um time
func get_team_players(team: Team) -> Array:
	var players = []
	for peer_id in player_teams:
		if player_teams[peer_id] == team:
			players.append(peer_id)
	return players

# Retorna contagem de jogadores por time
func get_team_counts() -> Dictionary:
	var counts = {
		Team.RED: 0,
		Team.BLUE: 0,
		Team.NEUTRAL: 0
	}
	
	for peer_id in player_teams:
		var team = player_teams[peer_id]
		counts[team] += 1
	
	return counts

# Auto-balancear times (atribui ao time com menos jogadores)
func auto_assign_team(peer_id: int):
	var counts = get_team_counts()
	
	var team = Team.RED
	if counts[Team.BLUE] < counts[Team.RED]:
		team = Team.BLUE
	
	assign_team(peer_id, team)

# Sincroniza cores dos times com todos os clientes (RPC)
@rpc("authority", "call_local", "reliable")
func rpc_sync_team_colors(red_color: Color, blue_color: Color):
	team_colors[Team.RED] = red_color
	team_colors[Team.BLUE] = blue_color
	print("[TEAM] Cores sincronizadas - Red: ", red_color, " Blue: ", blue_color)

# Sincroniza atribuição de time (RPC)
@rpc("authority", "call_local", "reliable")
func rpc_assign_team(peer_id: int, team: int):
	assign_team(peer_id, team as Team)

# Limpa todos os dados (para reiniciar partida)
func clear_all():
	player_teams.clear()
	team_leaders = {
		Team.RED: -1,
		Team.BLUE: -1
	}
	team_colors = {
		Team.RED: Color(0.9, 0.2, 0.2),
		Team.BLUE: Color(0.2, 0.5, 0.9)
	}
	print("[TEAM] Dados limpos")

