class_name PlayerEntity
extends CharacterBody3D

@onready var camera:Camera3D = $CameraPivot/ThirdPersonCamera
@onready var camera_pivot:Node3D = $CameraPivot
@onready var model := $IcySkin
@onready var health_manager := $HealthManager
@onready var anim_tree := $IcySkin/AnimationTree
@onready var shoot_anchor := $IcySkin/%ShootAnchor
@onready var current_controller := $TwoStickControllerAuto
@onready var interaction_area := $IcySkin/PlayerHand
@onready var position_resetter := $PositionResetter
@onready var start_position := global_transform.origin

@export var use_saved_controller:bool = true
@export var controller_schemes:Array[PackedScene]
@export var game_data:GameDataStore

@export var current_class: PlayerClass: set = _set_player_class
@export var inventory: Array = []
signal is_dead

func _set_player_class(new_class: PlayerClass):
	current_class = new_class
	if not is_inside_tree(): await ready
	
	if current_class:
		# Atualizar Vida
		health_manager.max_health = current_class.max_health
		health_manager.get_full_health()
		
		# Atualizar Velocidade (depende do controller)
		if current_controller and "speed" in current_controller:
			current_controller.speed = current_class.movement_speed
		
		# Atualizar Visual (Chapéu)
		# model.update_hat(current_class.hat_mesh)
		
		print("Classe alterada para: ", current_class.class_name_str)

@rpc("any_peer", "reliable")
func change_class_rpc(class_path: String):
	var class_res = load(class_path)
	if class_res is PlayerClass:
		current_class = class_res

func _ready():
	# Configurar authority se o nome for o ID do peer
	if name.is_valid_int():
		set_multiplayer_authority(name.to_int())
	
	# Só processa se for o dono do player (Multiplayer)
	if multiplayer.multiplayer_peer and not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)
		$CameraPivot/ThirdPersonCamera.current = false
		return

	# Adicionar sincronizador dinamicamente se estiver em rede
	if multiplayer.multiplayer_peer:
		var synchronizer = MultiplayerSynchronizer.new()
		var config = SceneReplicationConfig.new()
		config.add_property(".:position")
		config.add_property(".:rotation")
		synchronizer.replication_config = config
		add_child(synchronizer)

	game_data.controller_scheme_changed.connect(_on_controller_scheme_changed)
	if use_saved_controller:
		_on_controller_scheme_changed(game_data.controller_scheme)
	Dialogic.timeline_started.connect(_on_dialog_started)
	Dialogic.timeline_ended.connect(_on_dialog_ended)


func on_hit():
	model.play_on_hit(true)


func on_death():
	is_dead.emit()
	model.move_to_dead()
	#current_controller.process_mode = Node.PROCESS_MODE_DISABLED
	current_controller.on_death()
	GameManager.on_player_death()
	

func on_respawn():
	model.move_to_running()
	current_controller.on_respawn()
	health_manager.get_full_health()


func _on_dialog_started():
	current_controller.process_mode = Node.PROCESS_MODE_DISABLED

func _on_dialog_ended():
	current_controller.process_mode = Node.PROCESS_MODE_INHERIT

func _on_controller_scheme_changed(value):
	if current_controller:
		current_controller.queue_free()
	var new_controller = controller_schemes[value].instantiate()
	add_child(new_controller)
	new_controller.owner = self
	current_controller = new_controller
