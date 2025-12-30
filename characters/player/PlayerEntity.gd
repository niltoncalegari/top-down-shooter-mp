class_name PlayerEntity
extends CharacterBody3D

# Referências aos nós
@onready var camera:Camera3D = $CameraPivot/ThirdPersonCamera
@onready var camera_pivot:Node3D = $CameraPivot
@onready var model := $IcySkin
@onready var health_manager := $HealthManager
@onready var anim_tree := $IcySkin/AnimationTree
@onready var shoot_anchor := $IcySkin/%ShootAnchor
@onready var current_controller := $TwoStickControllerAuto
@onready var interaction_area := $IcySkin/PlayerHand
@onready var position_resetter := $PositionResetter

# Configuração
@export var controller_schemes:Array[PackedScene]
@export var game_data:GameDataStore
@export var current_class: PlayerClass: set = _set_player_class
@export var inventory: Array = []

signal is_dead

func _ready():
	# MULTIPLAYER: Configurar autoridade baseada no nome (ID do peer)
	if name.is_valid_int():
		set_multiplayer_authority(name.to_int())
	
	# Aguardar um frame para garantir que todos os nós filhos foram carregados
	await get_tree().process_frame
	
	# Configurar autoridade do sincronizador
	var sync = get_node_or_null("MultiplayerSynchronizer")
	if sync:
		sync.set_multiplayer_authority(get_multiplayer_authority())
		# CRÍTICO: Sincronizar o mais rápido possível (0 = cada frame)
		sync.delta_interval = 0.0
		print("Sincronizador configurado | Player: ", name, " | Authority: ", sync.get_multiplayer_authority())
	else:
		push_error("ERRO: MultiplayerSynchronizer não encontrado no player ", name)
	
	# Garantir que o AnimationTree está ativo para TODOS os players
	if anim_tree:
		anim_tree.active = true
	
	# Se NÃO for o dono deste personagem (é um personagem remoto):
	if not is_multiplayer_authority():
		# Desativa o controlador remoto
		if current_controller:
			current_controller.process_mode = Node.PROCESS_MODE_DISABLED
		
		# Desativa a câmera remota
		if camera:
			camera.current = false
		if camera_pivot:
			camera_pivot.visible = false
		
		print("✓ Player REMOTO ", name, " configurado para receber sincronização")
		return
	
	# Se FOR o dono (jogador local):
	print("✓ Player LOCAL ", name, " configurado para enviar sincronização")
	
	# Ativar câmera local
	if camera:
		camera.current = true
	
	# Conectar sinais de controle/dialogo
	if game_data:
		game_data.controller_scheme_changed.connect(_on_controller_scheme_changed)
	
	Dialogic.timeline_started.connect(_on_dialog_started)
	Dialogic.timeline_ended.connect(_on_dialog_ended)

# Debug: Verificar sincronização
var last_pos = Vector3.ZERO
var debug_timer = 0.0

func _process(delta):
	if not multiplayer.multiplayer_peer:
		return
	
	debug_timer += delta
	if debug_timer > 2.0:  # A cada 2 segundos
		debug_timer = 0.0
		
		# Para players remotos: verificar se estão recebendo updates
		if not is_multiplayer_authority():
			var moved = global_position.distance_to(last_pos) > 0.01
			if moved or velocity.length() > 0.1:
				print("👁️ REMOTO ", name, " | Pos:", global_position.snapped(Vector3.ONE * 0.1), 
					  " | Vel:", velocity.snapped(Vector3.ONE * 0.1), " | Moveu:", moved)
			last_pos = global_position

# CRÍTICO: Aplicar movimento sincronizado nos players remotos
func _physics_process(_delta):
	# Para players REMOTOS: aplicar os valores sincronizados
	if not is_multiplayer_authority():
		# O MultiplayerSynchronizer já atualizou position, rotation e velocity
		# Agora precisamos aplicar o movimento para mover o CharacterBody3D
		move_and_slide()
	# Para o player LOCAL: o controller já chama move_and_slide()

func _set_player_class(new_class: PlayerClass):
	current_class = new_class
	if not is_inside_tree(): 
		await ready
	
	if current_class:
		health_manager.max_health = current_class.max_health
		health_manager.get_full_health()
		
		if current_controller and "speed" in current_controller:
			current_controller.speed = current_class.movement_speed
		
		print("Classe alterada para: ", current_class.class_name_str)

@rpc("any_peer", "reliable")
func change_class_rpc(class_path: String):
	var class_res = load(class_path)
	if class_res is PlayerClass:
		current_class = class_res

func on_hit():
	if model and model.has_method("play_on_hit"):
		model.play_on_hit(true)

func on_death():
	is_dead.emit()
	if model and model.has_method("move_to_dead"):
		model.move_to_dead()
	if current_controller and current_controller.has_method("on_death"):
		current_controller.on_death()
	GameManager.on_player_death()

func on_respawn():
	if model and model.has_method("move_to_running"):
		model.move_to_running()
	if current_controller and current_controller.has_method("on_respawn"):
		current_controller.on_respawn()
	health_manager.get_full_health()

func _on_dialog_started():
	if current_controller:
		current_controller.process_mode = Node.PROCESS_MODE_DISABLED

func _on_dialog_ended():
	if current_controller:
		current_controller.process_mode = Node.PROCESS_MODE_INHERIT

func _on_controller_scheme_changed(value):
	if current_controller:
		current_controller.queue_free()
	var new_controller = controller_schemes[value].instantiate()
	add_child(new_controller)
	new_controller.owner = self
	current_controller = new_controller
