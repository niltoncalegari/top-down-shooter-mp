extends Node
class_name HealthManager
# HealthManager - Componente para gerenciar HP, dano e morte

signal health_changed(current_hp: float, max_hp: float)
signal damage_taken(amount: float, attacker_id: int)
signal healed(amount: float)
signal died(killer_id: int)
signal respawned()

# Stats
@export var max_health: float = 100.0
@export var auto_regen: bool = false
@export var regen_rate: float = 5.0  # HP por segundo
@export var regen_delay: float = 3.0  # Segundos sem tomar dano para iniciar regen

var current_health: float = 100.0
var is_dead: bool = false
var time_since_last_damage: float = 0.0

# Referência ao owner (PlayerEntity)
var owner_peer_id: int = -1

func _ready():
	current_health = max_health
	set_physics_process(false)  # Ativar apenas se tiver auto_regen

func _physics_process(delta):
	if not auto_regen or is_dead:
		return
	
	time_since_last_damage += delta
	
	# Iniciar regeneração após delay
	if time_since_last_damage >= regen_delay and current_health < max_health:
		heal(regen_rate * delta)

# Inicializa o HealthManager com valores específicos
func initialize(max_hp: float, owner_id: int):
	max_health = max_hp
	current_health = max_hp
	owner_peer_id = owner_id
	is_dead = false
	
	if auto_regen:
		set_physics_process(true)
	
	print("[HEALTH] Inicializado - Owner: ", owner_id, " HP: ", max_hp)

# Define HP máximo e restaura HP
func set_max_health(new_max: float):
	max_health = new_max
	current_health = new_max
	health_changed.emit(current_health, max_health)

# Aplica dano (chamado via RPC)
@rpc("any_peer", "call_local", "reliable")
func take_damage(amount: float, attacker_id: int = -1):
	if is_dead:
		return
	
	# Verificar friendly fire
	if attacker_id != -1 and owner_peer_id != -1:
		if TeamManager.are_teammates(owner_peer_id, attacker_id):
			print("[HEALTH] Friendly fire ignorado")
			return
	
	current_health = max(0, current_health - amount)
	time_since_last_damage = 0.0
	
	damage_taken.emit(amount, attacker_id)
	health_changed.emit(current_health, max_health)
	
	print("[HEALTH] Dano recebido - ", amount, " HP restante: ", current_health)
	
	# Feedback visual
	_show_damage_feedback()
	
	if current_health <= 0:
		die(attacker_id)

# Mata o jogador
func die(killer_id: int = -1):
	if is_dead:
		return
	
	is_dead = true
	print("[HEALTH] Morreu - Killer: ", killer_id)
	
	# Registrar kill e death no PlayerStatsManager
	if killer_id != -1 and killer_id != owner_peer_id and owner_peer_id != -1:
		PlayerStatsManager.record_kill(killer_id, owner_peer_id)
	
	if owner_peer_id != -1:
		PlayerStatsManager.record_death(owner_peer_id)
	
	died.emit(killer_id)
	
	# Desabilitar processamento
	set_physics_process(false)

# Cura o jogador
func heal(amount: float):
	if is_dead:
		return
	
	var old_health = current_health
	current_health = min(max_health, current_health + amount)
	
	var actual_heal = current_health - old_health
	if actual_heal > 0:
		healed.emit(actual_heal)
		health_changed.emit(current_health, max_health)
		print("[HEALTH] Curado - ", actual_heal, " HP atual: ", current_health)

# Ressuscita o jogador (usado no respawn)
@rpc("authority", "call_local", "reliable")
func respawn():
	current_health = max_health
	is_dead = false
	time_since_last_damage = 0.0
	
	health_changed.emit(current_health, max_health)
	respawned.emit()
	
	if auto_regen:
		set_physics_process(true)
	
	print("[HEALTH] Respawn - HP restaurado: ", max_health)

# Verifica se está vivo
func is_alive() -> bool:
	return not is_dead and current_health > 0

# Retorna porcentagem de vida
func get_health_percentage() -> float:
	if max_health == 0:
		return 0.0
	return (current_health / max_health) * 100.0

# Feedback visual de dano
func _show_damage_feedback():
	# Obter MeshInstance3D do owner
	var owner_node = get_parent()
	if not owner_node:
		return
	
	# Procurar por MeshInstance3D (skin do personagem)
	var mesh_instance = _find_mesh_instance(owner_node)
	if not mesh_instance:
		return
	
	# Criar efeito de flash vermelho
	_create_damage_flash(mesh_instance)

func _find_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	
	for child in node.get_children():
		var result = _find_mesh_instance(child)
		if result:
			return result
	
	return null

func _create_damage_flash(mesh: MeshInstance3D):
	# Criar tween para efeito de flash
	var tween = create_tween()
	
	# Obter material atual
	var material = mesh.get_surface_override_material(0)
	if not material:
		return
	
	# Salvar cor original
	var original_color = material.albedo_color
	
	# Flash vermelho
	tween.tween_property(material, "albedo_color", Color(1, 0.3, 0.3), 0.1)
	tween.tween_property(material, "albedo_color", original_color, 0.2)

# Força sincronização de HP (útil para debugging)
@rpc("any_peer", "call_local", "reliable")
func sync_health(new_health: float):
	current_health = clamp(new_health, 0, max_health)
	health_changed.emit(current_health, max_health)
