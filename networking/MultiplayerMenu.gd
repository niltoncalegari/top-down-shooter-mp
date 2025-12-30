extends Control

@onready var address_input = $VBoxContainer/AddressInput
@onready var status_label = $VBoxContainer/StatusLabel
@onready var user_label = $VBoxContainer/UserLabel

func _ready():
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.server_disconnected.connect(_on_server_disconnected)
	
	# Verificar se está logado
	if not AuthManager.is_logged_in():
		print("⚠️ Usuário não está logado!")
		# Aqui você pode redirecionar para a tela de login se necessário
		return
	
	# Atualizar label com nome do usuário
	var username = AuthManager.get_current_user()
	user_label.text = "👤 Logado como: " + username
	NetworkManager.player_info["name"] = username
	
	print("✅ MultiplayerMenu pronto | Usuário: ", username)

func _on_host_pressed():
	if not AuthManager.is_logged_in():
		status_label.text = "❌ Você precisa estar logado!"
		return
	
	var username = AuthManager.get_current_user()
	NetworkManager.player_info["name"] = username
	var err = NetworkManager.create_game()
	if err == OK:
		status_label.text = "🎮 Hosting on port " + str(NetworkManager.PORT)
	else:
		status_label.text = "❌ Error hosting: " + str(err)

func _on_join_pressed():
	if not AuthManager.is_logged_in():
		status_label.text = "❌ Você precisa estar logado!"
		return
	
	var username = AuthManager.get_current_user()
	NetworkManager.player_info["name"] = username
	var err = NetworkManager.join_game(address_input.text)
	if err == OK:
		status_label.text = "🔄 Connecting..."
	else:
		status_label.text = "❌ Error joining: " + str(err)

func _on_player_connected(peer_id, player_info_dict):
	# Quando o jogador local conecta, esconde o menu
	if peer_id == multiplayer.get_unique_id():
		status_label.text = "✅ Connected as " + player_info_dict["name"]
		# Dar um tempo para o spawner ser criado
		await get_tree().create_timer(0.2).timeout
		hide()

func _on_server_disconnected():
	status_label.text = "⚠️ Server disconnected"
	show()

func _on_logout_pressed():
	"""Botão de logout"""
	var username = AuthManager.get_current_user()
	print("🔐 Fazendo logout de: ", username)
	
	# Desconectar do servidor (se estiver conectado)
	NetworkManager.disconnect_from_server()
	
	# Fazer logout
	AuthManager.logout()
	
	# Voltar para a tela de login
	get_tree().change_scene_to_file("res://scenes/MainWithLogin.tscn")
	print("✅ Logout concluído, voltando para tela de login")

