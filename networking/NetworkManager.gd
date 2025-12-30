extends Node

# Sinais conforme a documentação oficial do Godot
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 10567
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 32

# Dicionário com informações de todos os jogadores conectados
var players = {}

# Informações do jogador local
var player_info = {"name": "Player"}

var players_loaded = 0

func _ready():
	# Conectar sinais do multiplayer conforme documentação
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func join_game(address = ""):
	if address == "":
		address = DEFAULT_SERVER_IP
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error != OK:
		print("Erro ao criar cliente: ", error)
		return error
	
	multiplayer.multiplayer_peer = peer
	print("Tentando conectar em ", address, ":", PORT)
	return OK

func create_game():
	DebugLogger.log_section("NetworkManager: Criando Servidor")
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error != OK:
		DebugLogger.write_log("❌ Erro ao criar servidor: " + str(error))
		print("Erro ao criar servidor: ", error)
		return error
	
	multiplayer.multiplayer_peer = peer
	players[1] = player_info
	DebugLogger.write_log("✓ Servidor criado na porta " + str(PORT))
	DebugLogger.write_log("✓ Host registrado como player 1")
	DebugLogger.write_log("✓ Emitindo player_connected(1, " + str(player_info) + ")")
	player_connected.emit(1, player_info)
	print("Servidor criado na porta ", PORT)
	return OK

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null

func disconnect_from_server():
	"""Desconecta do servidor atual (se conectado)"""
	if multiplayer.multiplayer_peer:
		print("🔌 Desconectando do servidor...")
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
		players.clear()
		players_loaded = 0
		print("✅ Desconectado com sucesso")
	else:
		print("⚠️ Não há conexão ativa para desconectar")

# Quando um peer conecta, envie as informações do jogador local
func _on_player_connected(id):
	DebugLogger.log_subsection("NetworkManager._on_player_connected")
	DebugLogger.write_log("  Peer conectado: " + str(id))
	DebugLogger.write_log("  Sou servidor: " + str(multiplayer.is_server()))
	DebugLogger.write_log("  Meu ID: " + str(multiplayer.get_unique_id()))
	DebugLogger.write_log("  Enviando _register_player.rpc_id(" + str(id) + ", " + str(player_info) + ")")
	_register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	DebugLogger.log_subsection("NetworkManager._register_player")
	DebugLogger.write_log("  Recebido de: " + str(new_player_id))
	DebugLogger.write_log("  Player info: " + str(new_player_info))
	DebugLogger.write_log("  Meu ID: " + str(multiplayer.get_unique_id()))
	DebugLogger.write_log("  Sou servidor: " + str(multiplayer.is_server()))
	
	players[new_player_id] = new_player_info
	DebugLogger.write_log("  ✓ Player " + str(new_player_id) + " registrado localmente")
	DebugLogger.write_log("  ✓ Emitindo player_connected(" + str(new_player_id) + ", " + str(new_player_info) + ")")
	player_connected.emit(new_player_id, new_player_info)

func _on_player_disconnected(id):
	players.erase(id)
	
	# Fazer logout do usuário
	AuthManager.logout_by_peer(id)
	
	player_disconnected.emit(id)

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	DebugLogger.log_section("NetworkManager: Conectado ao Servidor")
	DebugLogger.write_log("  Meu peer ID: " + str(peer_id))
	players[peer_id] = player_info
	DebugLogger.write_log("  ✓ Me registrei localmente como player " + str(peer_id))
	DebugLogger.write_log("  ✓ Emitindo player_connected(" + str(peer_id) + ", " + str(player_info) + ")")
	player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	
	# Fazer logout do usuário atual
	AuthManager.logout()
	
	server_disconnected.emit()

# Função para o servidor carregar a cena do jogo
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)

# Todo peer chama isso quando carregou a cena do jogo
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			# Aqui você pode chamar uma função para iniciar o jogo
			players_loaded = 0
