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
	# Configurar MultiplayerSpawner se estivermos em modo multiplayer
	if multiplayer.multiplayer_peer:
		var spawner = MultiplayerSpawner.new()
		spawner.spawn_path = self.get_path()
		spawner._set_spawnable_scenes([player_packed_scene.resource_path])
		add_child(spawner)
	
	find_game_elements() # find player, level and gameovermenu
	
	# No multiplayer, o servidor spawna os jogadores
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(spawn_player)
		multiplayer.peer_disconnected.connect(remove_player)
		# Spawna o player local do host
		spawn_player(1)
	
	if not player and level and level.skip_intro and not multiplayer.multiplayer_peer:
		spawn_player_local()
		
	if level: 
		level.introscene_finished.connect(initialise_player)
	if gameover_menu:
		gameover_menu.restart_pressed.connect(on_restart_pressed)
		gameover_menu.quit_pressed.connect(on_quit_pressed)


func find_game_elements():
	var children = get_children()
	for child in children:
		if child is PlayerEntity:
			player = child
		elif child is LevelManager:
			level = child
		elif child is GameOverMenu:
			gameover_menu = child


func initialise_player():
	if player:
		player.queue_free()
	
	if multiplayer.multiplayer_peer:
		if multiplayer.is_server():
			spawn_player(1)
	else:
		spawn_player_local()
		
	if player:
		player.camera.current = true


func spawn_player_local():
	player = player_packed_scene.instantiate()
	add_child(player)
	_setup_player_location(player)


func spawn_player(id: int):
	var p = player_packed_scene.instantiate()
	p.name = str(id)
	add_child(p)
	_setup_player_location(p)
	if id == multiplayer.get_unique_id():
		player = p


func remove_player(id: int):
	var p = get_node_or_null(str(id))
	if p:
		p.queue_free()


func _setup_player_location(p: PlayerEntity):
	if level:
		var spawn_point = level.get_node_or_null("PlayerStart")
		if spawn_point:
			p.global_transform = spawn_point.global_transform
		else:
			p.global_transform = level.player_start_point.global_transform
		
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
