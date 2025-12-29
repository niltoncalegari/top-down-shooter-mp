extends Control

@onready var address_input = $VBoxContainer/AddressInput
@onready var name_input = $VBoxContainer/NameInput
@onready var status_label = $VBoxContainer/StatusLabel

func _ready():
	NetworkManager.connection_failed.connect(_on_connection_failed)
	NetworkManager.connection_succeeded.connect(_on_connection_success)
	NetworkManager.server_disconnected.connect(_on_server_disconnected)

func _on_host_pressed():
	var err = NetworkManager.host_game(name_input.text)
	if err == OK:
		status_label.text = "Hosting..."
		hide()
	else:
		status_label.text = "Error hosting: " + str(err)

func _on_join_pressed():
	var err = NetworkManager.join_game(address_input.text, name_input.text)
	if err == OK:
		status_label.text = "Joining..."
	else:
		status_label.text = "Error joining: " + str(err)

func _on_connection_success():
	status_label.text = "Connected!"
	hide()

func _on_connection_failed():
	status_label.text = "Connection failed."

func _on_server_disconnected():
	status_label.text = "Server disconnected."
	show()

