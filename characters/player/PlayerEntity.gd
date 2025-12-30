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

# CRÍTICO: Configurar autoridade ANTES de _ready() para garantir sincronização
func _enter_tree():
	# MULTIPLAYER: Configurar autoridade baseada no nome (ID do peer)
	if name.is_valid_int():
		var authority_id = name.to_int()
		set_multiplayer_authority(authority_id)

func _ready():
	print("\n╔═══════════════════════════════════════")
	print("║ PlayerEntity._ready() iniciado")
	print("║ Nome: ", name)
	print("║ Meu peer ID: ", multiplayer.get_unique_id())
	print("║ Autoridade: ", get_multiplayer_authority())
	print("║ É meu?: ", is_multiplayer_authority())
	print("║ Sou servidor?: ", multiplayer.is_server())
	print("╚═══════════════════════════════════════")
	
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
		
		print("  ✓ Player REMOTO ", name, " configurado para RECEBER sincronização")
		print("    Posição inicial: ", global_position)
		print("╚═══════════════════════════════════════\n")
		return
	
	# Se FOR o dono (jogador local):
	print("  ✓ Player LOCAL ", name, " configurado para ENVIAR sincronização")
	print("    Posição inicial: ", global_position)
	print("╚═══════════════════════════════════════\n")
	
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
		# O MultiplayerSynchronizer já atualizou global_position, rotation e velocity
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
		
		# Atualizar visual da classe (cor do modelo)
		_update_class_visual()
		
		print("Classe alterada para: ", current_class.class_name_str)

func _update_class_visual():
	"""Atualiza a aparência visual do player baseado na classe"""
	if not current_class or not model:
		return
	
	# Definir cor baseada na classe
	var class_color: Color
	match current_class.class_name_str:
		"Guerreiro":
			class_color = Color(0.8, 0.2, 0.2)  # Vermelho - Tanque
		"Mago":
			class_color = Color(0.2, 0.2, 0.8)  # Azul - Mágico
		"Arqueiro":
			class_color = Color(0.2, 0.8, 0.2)  # Verde - Ágil
		"Sacerdote":
			class_color = Color(1.0, 1.0, 0.2)  # Amarelo - Suporte
		"Aldeão":
			class_color = Color(0.6, 0.6, 0.6)  # Cinza - Básico
		_:
			class_color = Color(1, 1, 1)  # Branco padrão
	
	# Encontrar e aplicar cor ao MeshInstance3D dentro do modelo
	var armature = model.get_node_or_null("Armature")
	if armature:
		var skeleton = armature.get_node_or_null("Skeleton3D")
		if skeleton:
			# Procurar pelo MeshInstance3D filho do Skeleton3D
			for child in skeleton.get_children():
				if child is MeshInstance3D:
					# Criar um material override com a cor da classe
					var mat = StandardMaterial3D.new()
					mat.albedo_color = class_color
					mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
					
					# Aplicar o material override
					child.set_surface_override_material(0, mat)
					print("   🎨 Cor aplicada no mesh: ", child.name, " | Cor: ", class_color)
	
	print("   🎨 Visual atualizado para classe: ", current_class.class_name_str)

@rpc("any_peer", "call_local", "reliable")
func change_class_rpc(class_path: String):
	print("🎩 RPC change_class_rpc recebido")
	print("   Player: ", name)
	print("   Classe: ", class_path)
	print("   Chamado por: ", multiplayer.get_remote_sender_id())
	print("   Meu ID: ", multiplayer.get_unique_id())
	
	var class_res = load(class_path)
	if class_res is PlayerClass:
		current_class = class_res
		print("   ✅ Classe alterada para: ", current_class.class_name_str)
		print("   HP: ", current_class.max_health, " | Speed: ", current_class.movement_speed, " | Damage: ", current_class.damage)
	else:
		push_error("   ❌ Falha ao carregar classe: ", class_path)

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
