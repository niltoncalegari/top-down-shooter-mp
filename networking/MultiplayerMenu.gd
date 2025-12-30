extends Control

@onready var address_input = $VBoxContainer/AddressInput
@onready var name_input = $VBoxContainer/NameInput
@onready var status_label = $VBoxContainer/StatusLabel

func _ready():
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.server_disconnected.connect(_on_server_disconnected)

func _on_host_pressed():
	NetworkManager.player_info["name"] = name_input.text
	var err = NetworkManager.create_game()
	if err == OK:
		status_label.text = "Hosting on port " + str(NetworkManager.PORT)
	else:
		status_label.text = "Error hosting: " + str(err)

func _on_join_pressed():
	NetworkManager.player_info["name"] = name_input.text
	var err = NetworkManager.join_game(address_input.text)
	if err == OK:
		status_label.text = "Connecting..."
	else:
		status_label.text = "Error joining: " + str(err)

func _on_player_connected(peer_id, player_info_dict):
	# Quando o jogador local conecta, esconde o menu
	if peer_id == multiplayer.get_unique_id():
		status_label.text = "Connected as " + player_info_dict["name"]
		# Dar um tempo para o spawner ser criado
		await get_tree().create_timer(0.2).timeout
		hide()

func _on_server_disconnected():
	status_label.text = "Server disconnected"
	show()

