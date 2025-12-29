extends Node

signal connection_failed
signal connection_succeeded
signal player_list_changed
signal server_disconnected

const DEFAULT_PORT = 10567
const MAX_PLAYERS = 32

var players = {}
var local_player_data = {"name": "Player"}

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connection_success)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game(username):
	local_player_data.name = username
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	if error != OK:
		return error
	multiplayer.multiplayer_peer = peer
	
	players[1] = local_player_data
	player_list_changed.emit()
	return OK

func join_game(address, username):
	local_player_data.name = username
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, DEFAULT_PORT)
	if error != OK:
		return error
	multiplayer.multiplayer_peer = peer
	return OK

func _on_player_connected(id):
	_register_player.rpc_id(id, local_player_data)

@rpc("any_peer", "reliable")
func _register_player(new_player_data):
	var id = multiplayer.get_remote_sender_id()
	players[id] = new_player_data
	player_list_changed.emit()

func _on_player_disconnected(id):
	players.erase(id)
	player_list_changed.emit()

func _on_connection_success():
	connection_succeeded.emit()

func _on_connection_failed():
	connection_failed.emit()
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	server_disconnected.emit()
	players.clear()
	multiplayer.multiplayer_peer = null

