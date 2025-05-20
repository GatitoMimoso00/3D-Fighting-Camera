@tool
extends Node3D

##--EXPORTS--##
@export var CharPJ1 : CharacterBody3D
@export var CharPJ2 : CharacterBody3D

##--PJs MOVEMENT VARIABLES--##
@onready var current_sidePJ1 : String = "LEFT"
@onready var current_sidePJ2 : String = "RIGHT"

##--OVERLAPPING HANDLING VARIABLES--##
@onready var direction_PUSH : Vector3 = Vector3.ZERO
@onready var distance_PJs : float = 0.0
@export var overlapp_distance : float = 0.0
@export var PUSH : float = 0.0

##--MISC--##
@onready var windowed_mode : bool = false
@onready var cam_switch : bool = true
@onready var vsync_mode : bool = true



func _ready() -> void:
	pass
	

func _process(delta: float) -> void:
	inputs()
	camera_switch()
	

func _physics_process(delta: float) -> void:
	direction_PUSH = CharPJ1.global_position.direction_to(CharPJ2.global_position)
	distance_PJs = CharPJ1.global_position.distance_to(CharPJ2.global_position)
	
	overlapping_handle(delta)

####----####
func inputs():
	##PJ1##
	#UP
	if InputMap.has_action("upPJ1"):
		if (Input.is_action_pressed("upPJ1")):
			CharPJ1.up = true
		if (Input.is_action_just_released("upPJ1")):
			CharPJ1.up = false
	#DOWN
	if InputMap.has_action("downPJ1"):
		if (Input.is_action_pressed("downPJ1")):
			CharPJ1.down = true
		if (Input.is_action_just_released("downPJ1")):
			CharPJ1.down = false
	#FORWARD
	if InputMap.has_action("forwardPJ1"):
		if (Input.is_action_pressed("forwardPJ1")):
			if (current_sidePJ1 == "LEFT"):
				CharPJ1.forward = true
				CharPJ1.backward = false
			elif (current_sidePJ1 == "RIGHT"):
				CharPJ1.forward = false
				CharPJ1.backward = true
		if (Input.is_action_just_released("forwardPJ1")):
			if (current_sidePJ1 == "LEFT"):
				CharPJ1.forward = false
				CharPJ1.backward = false
			elif (current_sidePJ1 == "RIGHT"):
				CharPJ1.forward = false
				CharPJ1.backward = false
	#BACKWARD
	if InputMap.has_action("backwardPJ1"):
		if (Input.is_action_pressed("backwardPJ1")):
			if (current_sidePJ1 == "LEFT"):
				CharPJ1.backward = true
				CharPJ1.forward = false
			elif (current_sidePJ1 == "RIGHT"):
				CharPJ1.backward = false
				CharPJ1.forward = true
		if (Input.is_action_just_released("backwardPJ1")):
			if (current_sidePJ1 == "LEFT"):
				CharPJ1.backward = false
				CharPJ1.forward = false
			elif (current_sidePJ1 == "RIGHT"):
				CharPJ1.backward = false
				CharPJ1.forward = false
				
	
	##PJ2##
	#UP
	if InputMap.has_action("upPJ2"):
		if (Input.is_action_pressed("upPJ2")):
			CharPJ2.up = true
		if (Input.is_action_just_released("upPJ2")):
			CharPJ2.up = false
	#DOWN
	if InputMap.has_action("downPJ2"):
		if (Input.is_action_pressed("downPJ2")):
			CharPJ2.down = true
		if (Input.is_action_just_released("downPJ2")):
			CharPJ2.down = false
	#FORWARD
	if InputMap.has_action("forwardPJ2"):
		if (Input.is_action_pressed("forwardPJ2")):
			if (current_sidePJ2 == "LEFT"):
				CharPJ2.forward = true
				CharPJ2.backward = false
			elif (current_sidePJ2 == "RIGHT"):
				CharPJ2.forward = false
				CharPJ2.backward = true
		if (Input.is_action_just_released("forwardPJ2")):
			if (current_sidePJ2 == "LEFT"):
				CharPJ2.forward = false
				CharPJ2.backward = false
			elif (current_sidePJ2 == "RIGHT"):
				CharPJ2.forward = false
				CharPJ2.backward = false
	#BACKWARD
	if InputMap.has_action("backwardPJ2"):
		if (Input.is_action_pressed("backwardPJ2")):
			if (current_sidePJ2 == "LEFT"):
				CharPJ2.backward = true
				CharPJ2.forward = false
			elif (current_sidePJ2 == "RIGHT"):
				CharPJ2.backward = false
				CharPJ2.forward = true
		if (Input.is_action_just_released("backwardPJ2")):
			if (current_sidePJ2 == "LEFT"):
				CharPJ2.backward = false
				CharPJ2.forward = false
			elif (current_sidePJ2 == "RIGHT"):
				CharPJ2.backward = false
				CharPJ2.forward = false
	

func overlapping_handle(delta):
	##DIFF
	if (distance_PJs <= 1.0):
		PUSH = (1.0 - distance_PJs) * 10.5
	else:
		PUSH = 0.0
	
	if (PUSH == 0.0):
		CharPJ1.enemyPUSH = Vector3.ZERO
		CharPJ2.enemyPUSH = Vector3.ZERO
	else:
		CharPJ1.enemyPUSH = direction_PUSH * (-PUSH)
		CharPJ2.enemyPUSH = direction_PUSH * PUSH
	

func camera_switch():
	#WINDOWED MODE
	if InputMap.has_action("window_mode"):
		if (Input.is_action_just_pressed("window_mode")):
			if (windowed_mode == true):
				windowed_mode  = false
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				windowed_mode  = true
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	#CAM SWITCH
	if (InputMap.has_action("cam_switch")):
		if (Input.is_action_just_pressed("cam_switch")):
			if (cam_switch == true):
				cam_switch = false
				get_parent().get_node("CameraManager/Camera3D").set_deferred("current", false)
				get_parent().get_node("Camera3DOuter").set_deferred("current", true)
			else:
				cam_switch = true
				get_parent().get_node("CameraManager/Camera3D").set_deferred("current", true)
				get_parent().get_node("Camera3DOuter").set_deferred("current", false)
	
	#VSYNC
	if (InputMap.has_action("vsync")):
		if (Input.is_action_just_pressed("vsync")):
			if (vsync_mode == true):
				vsync_mode = false
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED, 0)
				Engine.max_fps = 60
			else:
				vsync_mode = true
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED, 0)
				Engine.max_fps = 0
	
	
