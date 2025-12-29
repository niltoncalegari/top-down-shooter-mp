extends Area3D

@export var class_to_give: PlayerClass

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is PlayerEntity:
		if body.is_multiplayer_authority():
			body.change_class_rpc.rpc(class_to_give.resource_path)
			print("Player mudou para ", class_to_give.class_name_str)

