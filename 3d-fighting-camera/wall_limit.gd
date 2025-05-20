@tool
extends StaticBody3D

#COLL REFERNCE
@onready var coll_pj1 = get_node("WallPJ1")
@onready var coll_pj1_x : float = 0.0
@onready var coll_pj1_z : float = 0.0

@onready var coll_pj2 = get_node("WallPJ2")
@onready var coll_pj2_x : float = 0.0
@onready var coll_pj2_z : float = 0.0

#PJs REFERNCE
@export var PJ1 : CharacterBody3D
@export var PJ2 : CharacterBody3D

#PJAng
@onready var PJ1ang : float = 0.0
@onready var PJ2ang : float = 0.0

#AXIS ROTATION
const axis : Vector3 = Vector3(0.0, 0.0, 0.0)
const radius : float = 20.0

#LIMITER NORMAL 
@onready var PJ1_WALL_NORMAL : Vector3
@onready var PJ2_WALL_NORMAL : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	pass
	
	
func _physics_process(_delta: float) -> void:
	##PJ-AXIS ANGLE
	#PJ1
	if (PJ1 != null):
		PJ1ang = atan2(PJ1.current_position.z, PJ1.current_position.x)
		if (PJ1ang < 0.0):
			PJ1ang += 2*PI
	#PJ2
	if (PJ2 != null):
		PJ2ang = atan2(PJ2.current_position.z, PJ2.current_position.x)
		if (PJ2ang < 0.0):
			PJ2ang += 2*PI
	
	
	##WALL COLL ROTATE (circulo unitario actua como riculo de r =15)
	#PJ1
	coll_pj1_x = radius * cos(PJ1ang)
	coll_pj1_z = radius * sin(PJ1ang)
	coll_pj1.position = Vector3(coll_pj1_x, 0.0, coll_pj1_z)
	coll_pj1.rotation_degrees.y = rad_to_deg((-1* PJ1ang)+PI/2 )
	#PJ2
	coll_pj2_x = radius * cos(PJ2ang)
	coll_pj2_z = radius * sin(PJ2ang)
	coll_pj2.position = Vector3(coll_pj2_x, 0.0, coll_pj2_z)
	coll_pj2.rotation_degrees.y = rad_to_deg(-1 * (PJ2ang + PI/2))
	
	wall_normal_getter()

##--WALL NORMAL--##
func wall_normal_getter():
	PJ1_WALL_NORMAL = coll_pj1.global_position.direction_to(Vector3(0.0, 0.0, 0.0))
	PJ2_WALL_NORMAL = coll_pj2.global_position.direction_to(Vector3(0.0, 0.0, 0.0))
