class_name LevelManager extends Node3D

@export var skip_intro:bool = false

@export var camera_start_rotation:Vector3 = Vector3(-35, 60, 0)
@onready var player_start_point:Marker3D = %PlayerStartingPoint

signal introscene_finished

func _ready():
	# NOTE: both the animation player or the dialog system can flag the end of a cutscene
	# depending on whether the cutscene is dialog-driven or animation-driven.
	var cutscene_manager = get_node_or_null("CutSceneManager")
	if cutscene_manager:
		cutscene_manager.animation_finished.connect(on_cutscene_finished)
	
	Dialogic.signal_event.connect(on_cutscene_finished)
	
	if not skip_intro and cutscene_manager:
		cutscene_manager.play("Scene1_Introduction")
		#cutscene_manager.seek(27.99,true)
	elif cutscene_manager:
		cutscene_manager.process_mode = Node.PROCESS_MODE_DISABLED

func on_cutscene_finished(anim_name:String):
	var cutscene_manager = get_node_or_null("CutSceneManager")
	if not cutscene_manager: return

	if anim_name == "Scene1_Introduction":
		introscene_finished.emit() #Gamemanager will spawn a player and change camera
		Dialogic.Inputs.resume()
		cutscene_manager.play("Opening")
	if anim_name == "Opening":
		cutscene_manager.process_mode = Node.PROCESS_MODE_DISABLED
		Dialogic.start("level1_drmegadroon")
	if anim_name == "Scene2_Ending": # from Dialogic
		GameManager.get_player().camera.current = true
		var switch:SwitchComponent = %DoorToTraining.get_node_or_null("SwitchComponent")
		if switch:
			switch.on_interaction(true)
		cutscene_manager.play("Simple_Transition")
	if anim_name == "Simple_Transition":
		cutscene_manager.process_mode = Node.PROCESS_MODE_DISABLED
		

func on_card_picked_up():
	var cutscene_manager = get_node_or_null("CutSceneManager")
	if cutscene_manager:
		cutscene_manager.process_mode = Node.PROCESS_MODE_INHERIT
		cutscene_manager.get_camera().current = true
		cutscene_manager.play("Scene2_Opening_Training")
	
func on_gun_picked_up():
	pass
