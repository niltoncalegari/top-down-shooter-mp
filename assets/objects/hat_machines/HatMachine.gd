extends Area3D

@export var class_to_give: PlayerClass

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is PlayerEntity:
		# Apenas o dono do player pode mudar sua classe
		if body.is_multiplayer_authority():
			print("🎩 Player ", body.name, " entrando na Hat Machine: ", class_to_give.class_name_str)
			# Chamar RPC para sincronizar em TODOS os clientes
			body.change_class_rpc.rpc(class_to_give.resource_path)

