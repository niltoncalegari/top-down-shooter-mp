extends Control
# PlayerStatsHUD - Mostra as estatísticas do jogador na tela

@onready var username_label = $Panel/VBoxContainer/UsernameLabel
@onready var class_label = $Panel/VBoxContainer/ClassLabel
@onready var kills_label = $Panel/VBoxContainer/StatsContainer/KillsLabel
@onready var deaths_label = $Panel/VBoxContainer/StatsContainer/DeathsLabel
@onready var kd_label = $Panel/VBoxContainer/StatsContainer/KDLabel

var current_peer_id: int = 0

func _ready():
	# Conectar sinais do PlayerStatsManager
	PlayerStatsManager.player_killed.connect(_on_player_killed)
	PlayerStatsManager.player_died.connect(_on_player_died)
	
	# Pegar o peer_id local
	current_peer_id = multiplayer.get_unique_id()
	
	# Atualizar display inicial
	_update_display()
	
	print("[STATS] PlayerStatsHUD inicializado")

func _process(_delta):
	# Atualizar a cada frame (pode otimizar para atualizar só quando mudar)
	_update_display()

func _update_display():
	var stats = PlayerStatsManager.get_player_stats(current_peer_id)
	
	if stats.is_empty():
		username_label.text = "Aguardando..."
		return
	
	# Atualizar labels
	username_label.text = " " + stats.get("username", "Player")
	class_label.text = " " + stats.get("class", "villager").capitalize()
	kills_label.text = " Kills: " + str(stats.get("kills", 0))
	deaths_label.text = " Deaths: " + str(stats.get("deaths", 0))
	
	# Calcular K/D ratio
	var kills = stats.get("kills", 0)
	var deaths = stats.get("deaths", 0)
	var kd_ratio = float(kills) / max(1, deaths) if deaths > 0 else float(kills)
	kd_label.text = "[STATS] K/D: %.2f" % kd_ratio

func _on_player_killed(killer_id: int, victim_id: int):
	if killer_id == current_peer_id or victim_id == current_peer_id:
		_update_display()

func _on_player_died(player_id: int):
	if player_id == current_peer_id:
		_update_display()

