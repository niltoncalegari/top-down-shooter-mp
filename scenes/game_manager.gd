class_name GameManager extends Node3D

@export var player_packed_scene:PackedScene = null
static var gameover_menu: Control = null
static var player:PlayerEntity = null
static var level:LevelManager = null

static func get_player()->PlayerEntity:
	return player

static func has_player()->bool:
	return true if player else false

static func on_pickup_item(name:String):
	if player:
		player.inventory.append(name)
	if not level:
		return
	if name == "building_card":
		level.on_card_picked_up()

func _ready():
	# Conectar aos sinais do NetworkManager
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.player_disconnected.connect(_on_player_disconnected)
	
	_find_game_elements()

func _find_game_elements():
	var children = get_children()
	for child in children:
		if child is LevelManager:
			level = child
		elif child is GameOverMenu:
			gameover_menu = child
	
	if level: 
		level.introscene_finished.connect(initialise_player)
	if gameover_menu:
		gameover_menu.restart_pressed.connect(on_restart_pressed)
		gameover_menu.quit_pressed.connect(on_quit_pressed)

func _on_player_connected(peer_id, player_info_dict):
	print("========================================")
	print("Player connected: ID=", peer_id, " | Is Server: ", multiplayer.is_server())
	print("========================================")
	
	# Se for o servidor, spawnar o jogador
	if multiplayer.is_server():
		print("Servidor: Spawnando player ", peer_id)
		_spawn_player(peer_id)
		
		# Enviar jogadores existentes para o novo client
		if peer_id != 1:
			# Aguardar para garantir que o player foi criado
			await get_tree().create_timer(0.2).timeout
			
			print("Servidor: Enviando players existentes para client ", peer_id)
			var sent_count = 0
			for child in get_children():
				if child is PlayerEntity:
					var existing_id = child.name.to_int()
					if existing_id != peer_id and existing_id > 0:
						sent_count += 1
						print("  -> Enviando player ", existing_id, " | Pos: ", child.global_position)
						_create_player.rpc_id(peer_id, existing_id, child.global_position)
			
			print("Total de ", sent_count, " players existentes enviados")

func _on_player_disconnected(peer_id):
	print("Player disconnected: ", peer_id)
	var p = get_node_or_null(str(peer_id))
	if p:
		p.queue_free()

var spawn_point_index = 0

func _spawn_player(id: int):
	var spawn_pos = Vector3.ZERO
	if level:
		var spawn_point_name = "SpawnPoint" + str(spawn_point_index + 1)
		var spawn_point = level.get_node_or_null(spawn_point_name)
		
		if spawn_point:
			spawn_pos = spawn_point.global_transform.origin
			print("Usando ", spawn_point_name, " em ", spawn_pos)
		else:
			# Fallback: padrão circular
			var angle = (spawn_point_index * PI / 2.0)
			spawn_pos = Vector3(cos(angle) * 5.0, 0.5, sin(angle) * 5.0)
			print("Usando spawn circular: ", spawn_pos)
		
		spawn_point_index += 1
	
	_create_player.rpc(id, spawn_pos)

@rpc("authority", "call_local", "reliable")
func _create_player(id: int, pos: Vector3):
	print("━━━ _create_player RPC ━━━")
	print("  Target ID: ", id)
	print("  Position: ", pos)
	print("  Sender: ", multiplayer.get_remote_sender_id())
	print("  Local ID: ", multiplayer.get_unique_id())
	print("  Is Server: ", multiplayer.is_server())
	
	# Verificar se já existe
	if has_node(str(id)):
		print("  ⚠️ AVISO: Player ", id, " já existe! Pulando.")
		return
	
	print("  ➜ Instanciando player...")
	var p = player_packed_scene.instantiate()
	p.name = str(id)
	p.set_multiplayer_authority(id)
	p.global_position = pos
	
	print("  ➜ Adicionando à árvore...")
	add_child(p, true)  # force_readable_name = true
	
	# Aguardar para garantir que tudo foi inicializado
	await get_tree().process_frame
	
	# Verificar sincronizador
	var sync = p.get_node_or_null("MultiplayerSynchronizer")
	if sync:
		print("  ✓ Sincronizador OK | Authority: ", sync.get_multiplayer_authority())
	else:
		print("  ❌ Sincronizador FALTANDO!")
	
	# Se for o jogador local, salvar referência
	if id == multiplayer.get_unique_id():
		player = p
		print("  ✓✓✓ PLAYER LOCAL CRIADO")
	else:
		print("  ✓✓✓ PLAYER REMOTO CRIADO")
	
	print("━━━━━━━━━━━━━━━━━━━━━━━")

func initialise_player():
	pass  # Will be implemented when needed

func spawn_player_local():
	player = player_packed_scene.instantiate()
	add_child(player)
	_setup_player_location(player)

func _setup_player_location(p: PlayerEntity):
	if level:
		var spawn_point = level.get_node_or_null("PlayerStart")
		var pos = Vector3.ZERO
		if spawn_point:
			pos = spawn_point.global_transform.origin
		else:
			pos = level.player_start_point.global_transform.origin
		
		pos.x += randf_range(-2.0, 2.0)
		pos.z += randf_range(-2.0, 2.0)
		p.global_position = pos
		
		if "camera_start_rotation" in level:
			p.camera_pivot.rotation_degrees = level.camera_start_rotation
	p.position_resetter.update_reset_position()

static func on_player_death():
	if gameover_menu:
		gameover_menu.show()

func on_quit_pressed():
	get_tree().quit()

func on_restart_pressed():
	if player:
		player.position_resetter.reset_position()
		player.on_respawn()
	if gameover_menu: 
		gameover_menu.hide()
