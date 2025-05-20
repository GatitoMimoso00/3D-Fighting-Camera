@tool
extends CharacterBody3D

##--EXPORTS--##
@export var FM : Node3D

#SELF
@onready var jumping : bool = false
@onready var jmp_ascending : bool = true
@onready var current_position : Vector3 = Vector3.ZERO

#MISC
@export var enemy : CharacterBody3D
@onready var current_enemyPOS : Vector3
@onready var current_side : String
@onready var enemyPUSH : Vector3

#BUTTONS
@onready var up : bool = false
@onready var down : bool = false
@onready var forward : bool = false
@onready var backward : bool = false

#PHYSICS
#H_component front = forward or backward movement
#V_component height = vertical movement
#L_component lateral = side step movement
@onready var H_component : Vector3 = Vector3(0.0, 0.0, 0.0)
@onready var V_component : Vector3 = Vector3(0.0, 0.0, 0.0)
@onready var L_component : Vector3 = Vector3(0.0, 0.0, 0.0)
@onready var VELOCITY : Vector3 = Vector3(0.0, 0.0, 0.0)
const SPEED : float = 7.0
@onready var V_JMP_SPEED : float = 7.0
@onready var H_JMP_SPEED : float = 7.0
@onready var coll_1 : KinematicCollision3D
@onready var coll_2 : KinematicCollision3D
@onready var coll_3 : KinematicCollision3D

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
	

func _physics_process(delta: float) -> void:
	#UPDATING SELF POS
	current_position = self.global_position
	#UPDATING ENEMY POS
	current_enemyPOS = enemy.global_position
	current_side = FM.current_sidePJ1
	
	#SCALE LOCKING
	self.scale.x = 1
	self.scale.y = 1
	self.scale.z = 1
	
	#PROCESSING BUTTONS DIRECTION
	if (jumping == false):
		#MOVING CHAR
		self.look_at(current_enemyPOS)
		self.rotation.x = 0
		self.rotation.y += PI
		self.rotation.z = 0
		input_mov()
		V_component = Vector3(0.0, -7.0, 0.0)
	elif (jumping == true):
		jmp_movement()
	##
	VELOCITY = H_component + V_component + L_component
	coll_1 = move_and_collide((VELOCITY + enemyPUSH) * delta)
	if (coll_1):
		var coll_1_normal : Vector3 = coll_1.get_normal()
		var coll_1_slide : Vector3 = coll_1.get_remainder().slide(coll_1_normal)
		coll_2 = move_and_collide(coll_1_slide)
		if (coll_2):
			print("2nd coll")
			var coll_2_normal : Vector3 = coll_2.get_normal()
			var coll_2_slide : Vector3 = coll_2.get_remainder().slide(coll_2_normal)
			coll_3 = move_and_collide(coll_2_slide)
			if (coll_3):
				var coll_3_normal : Vector3 = coll_3.get_normal()
				var coll_3_slide : Vector3 = coll_3.get_remainder().slide(coll_3_normal)
				move_and_collide(coll_3_slide)

######
func input_mov():
	#UP
	if (up == true) and ((down == false) and (forward == false) and (backward == false)):
		H_component = Vector3.ZERO
		V_component = Vector3.ZERO
		if (current_side == "LEFT"):
			L_component = Vector3(cos(self.rotation.y) * SPEED, 0.0, sin(self.rotation.y) * -SPEED)
		else:
			L_component = Vector3(cos(self.rotation.y) * -SPEED, 0.0, sin(self.rotation.y) * SPEED)
	#DOWN
	elif (down == true) and ((forward == false) and (backward == false) and (up == false)):
		H_component = Vector3.ZERO
		V_component = Vector3.ZERO
		if (current_side == "LEFT"):
			L_component = Vector3(cos(self.rotation.y) * -SPEED, 0.0, sin(self.rotation.y) * SPEED)
		else:
			L_component = Vector3(cos(self.rotation.y) * SPEED, 0.0, sin(self.rotation.y) * -SPEED)
	#FORWARD
	elif (forward == true) and ((backward == false) and (up == false) and (down == false)):
		H_component = Vector3(sin(self.rotation.y) * SPEED, 0.0, cos(self.rotation.y) * SPEED)
		V_component = Vector3.ZERO
		L_component = Vector3.ZERO
	#BACKWARD
	elif (backward == true) and ((up == false) and (down == false) and (forward == false)):
		H_component = Vector3(sin(self.rotation.y) * -SPEED, 0.0, cos(self.rotation.y) * -SPEED)
		V_component = Vector3.ZERO
		L_component = Vector3.ZERO
	##JMP
	#JMP FORWARD
	elif ((up == true) and (forward == true)) and ((backward == false) and (down == false)):
		up = false
		down = false
		forward = false
		backward = false
		self.global_position.y = 0.0
		jumping = true
		jmp_ascending = true
		L_component = Vector3.ZERO
		H_JMP_SPEED = 7.0
	#JMP BACKWARD
	elif ((up == true) and (backward == true)) and ((forward == false) and (down == false)):
		up = false
		down = false
		forward = false
		backward = false
		self.global_position.y = 0.0
		jumping = true
		jmp_ascending = true
		L_component = Vector3.ZERO
		H_JMP_SPEED = -7.0
	##NO MOV
	else:
		H_component = Vector3.ZERO
		V_component = Vector3.ZERO
		L_component = Vector3.ZERO
	

func jmp_movement():
	if (self.global_position.y >= 3.0):
		jmp_ascending = false
		V_JMP_SPEED = -7.0
	
	H_component = Vector3(sin(self.rotation.y) * H_JMP_SPEED, 0.0, cos(self.rotation.y) * H_JMP_SPEED)
	V_component = Vector3(0.0, V_JMP_SPEED,0.0)
	L_component = Vector3.ZERO
	
	if (jmp_ascending == false) and (self.global_position.y <= 0.0):
		H_component = Vector3.ZERO
		V_component = Vector3.ZERO
		L_component = Vector3.ZERO
		V_JMP_SPEED = 7.0
		H_JMP_SPEED = 7.0
		jumping = false
		self.global_position.y = 0.0
	
