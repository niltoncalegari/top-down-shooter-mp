extends Node

var log_file: FileAccess
var log_path: String = "user://multiplayer_debug.log"
var real_path: String = ""

func _ready():
	# Obter o caminho real do arquivo
	real_path = ProjectSettings.globalize_path(log_path)
	
	# Abrir arquivo de log
	log_file = FileAccess.open(log_path, FileAccess.WRITE)
	if log_file:
		write_log("=".repeat(80))
		write_log("MULTIPLAYER DEBUG LOG - " + Time.get_datetime_string_from_system())
		write_log("=".repeat(80))
		write_log("Arquivo de log: " + real_path)
		write_log("Sistema inicializado")
		write_log("")
		print("📝 Log sendo salvo em: " + real_path)
	else:
		push_error("Não foi possível criar arquivo de log em: " + log_path)

func write_log(message: String):
	if log_file:
		var timestamp = "[%s] " % Time.get_time_string_from_system()
		var full_message = timestamp + message
		log_file.store_line(full_message)
		log_file.flush()  # Forçar escrita imediata
	
	# Também printar no console
	print(message)

func log_section(title: String):
	var separator = "=".repeat(80)
	write_log("")
	write_log(separator)
	write_log(title.to_upper())
	write_log(separator)

func log_subsection(title: String):
	write_log("")
	write_log("--- " + title + " ---")

func log_player_state(player: Node):
	if not player:
		write_log("  Player é NULL!")
		return
	
	write_log("  Player Name: " + str(player.name))
	write_log("  Position: " + str(player.global_position))
	write_log("  Multiplayer Authority: " + str(player.get_multiplayer_authority()))
	
	if player.has_node("MultiplayerSynchronizer"):
		var sync = player.get_node("MultiplayerSynchronizer")
		write_log("  Sync Authority: " + str(sync.get_multiplayer_authority()))
		write_log("  Sync Active: " + str(sync.is_multiplayer_authority()))
		if sync.replication_config:
			write_log("  Replication Config: " + str(sync.replication_config.get_properties()))
	else:
		write_log("  ❌ Sem MultiplayerSynchronizer!")
	
	if "velocity" in player:
		write_log("  Velocity: " + str(player.velocity))

func log_tree_structure(node: Node, indent: int = 0):
	var prefix = "  ".repeat(indent)
	write_log(prefix + "→ " + node.name + " (" + node.get_class() + ")")
	
	for child in node.get_children():
		log_tree_structure(child, indent + 1)

func _exit_tree():
	if log_file:
		log_section("Sessão finalizada")
		log_file.close()
