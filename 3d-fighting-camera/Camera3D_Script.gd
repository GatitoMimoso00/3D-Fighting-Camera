@tool
extends Node3D

####--EXPORTS--####
#PJ1 used to get PJ1 position
#PJ2 used to get PJ2 position
@export var PJ1 : CharacterBody3D
@export var PJ2 : CharacterBody3D
#FM refers to the node that controls the PJ, current_sides and other values can be passed to this
@export var FM : Node3D
#Cam refers to the camera node used
@export var Cam : Camera3D
#Label to know PJs sides
@export var Sides_Label : Label3D

####--DIRECTION & SENSES VARIABLES--####
## PERPENDICULAR_VECTOR_GETTER()
#PJ1_Pos, PJ2_Pos, Vector_PJ, Perp_Vector_PJ and MidPoint_PJ are 2D Vectors because 3rd component is useless for calculation
@onready var PJ1_Pos : Vector2
@onready var PJ2_Pos : Vector2
#Vector_PJ is the Vector that goes from PJ1 to PJ2, used to get the Perpendicular Vector
#used by the Camera
@onready var Vector_PJ : Vector2
@onready var Perp_Vector_PJ : Vector2
#MidPoint_PJ is the mid point between PJs, used by the camera to stay between PJs
@onready var MidPoint_PJ : Vector2
#PJ1_Vertical_Pos and PJ2_Vertical_Pos stores the vertical component of PJs
@onready var PJ1_Vertical_Pos : float
@onready var PJ2_Vertical_Pos : float
#diff_h stores the height between PJs
@onready var Diff_h : float 
#Distance_PJ distance between PJs, used as conditional to trigger some action
@onready var Distance_PJ : float = 5.0
#Cam_Virtual_Direction current direction (parallel to Perp_Vector_PJ) wich is follow by the camera
#such vector's sense is ignored,  
@onready var Cam_Virtual_Direction : Vector2
#Cam_YTarget_rot is the angle that must rotate de camera to look the PJs
@onready var Cam_YTarget_rot : float = 0.0
## CAMERA_VIRTUAL_SETTER()
#Cam_Virtual_Rot and Cam_Virtual_Pos contain the angle that Camera must rotate to and the position taht the camera must be
@onready var Cam_Virtual_Rot : Vector3
@onready var Cam_Virtual_Pos : Vector3


####--PJ SIDES VARIABLES--####
#CamtoCenter_vector Vector from Camera position to Midpoint, Vector creates the line
#that separate Left from Right side
@onready var CamtoCenter_vector : Vector3
#PJ1Cam_vector Vector from Camera to PJ1
@onready var PJ1Cam_vector : Vector3
#PJ1_crossed Cross Product used to determinate wich side is, in relation to CamtoCenter_vector
@onready var PJ1_crossed : Vector3
#current_sides stores the sides
@onready var current_sides : String = "P1_P2"


####--CALCULOUS VARIABLES--####
#Direction and sense
@onready var Scalar_Proj : Vector2
@onready var Ang_Diff : float = 0.0
#PJs sides
@onready var Dot_Prod : float


####--INTERPOLATION VARIABLES DECLARATION--####
#Interpolated is the interpolated results between the current cam pos/rot and Cam_Virtual
#used to smoothly move the camera
@onready var Interpolated_Rot : Vector3 = Vector3(0.0, 0.0, 0.0)
@onready var Interpolated_Pos : Vector3 = Vector3(0.0, 0.0, 0.0)


####--KNOBS--####
##Values to tweek for desirable trasition speed and movement
#Min rot of PJs to start rotating the Cam
@export var min_degree_threshold : float = deg_to_rad(1.0)
##Range in wich cam can rot and mov freely
##Useful to avoid abrupt camera movement when PJs are very close
#min_distance_threshold must be overpass for camera to mov/rot
#max_distance_threshold when overpass camera zooms out
@export var min_distance_threshold : float = 0.5
@export var max_distance_threshold : float = 8.0
@onready var blocked_cam : bool = false
##Cam distance to MidPoint_PJ range 
@export var min_cam_distance : float = 6.0
@export var max_cam_distance : float = 10.0
##Cam height ranges
@export var min_cam_height : float = 2.0
@export var max_cam_height : float = 4.0
##Cam axis rotations
#X-Axis (Top down view)
@export var min_topdownview_deg : float = deg_to_rad(-9.0)
@export var max_topdownview_deg : float = deg_to_rad(-5.0)
#Z-Axis (Tilt view)
@export var min_tilt_deg : float = deg_to_rad(0.0)
@export var max_tilt_deg : float = deg_to_rad(0.0)
#height_threshold use to store the difference of height between PJs, used as conditional to trigger some action
@export var height_threshold : float = 2.0

##--WEIGHTS--##
##Velocity of interpolation
##Lower values means slow movement interpolation
##Higher values means fast movement interpolation
#ROTATIONS
#XAxis_Rot_weigth how fast camera to look to MidPoint_PJ onthe Vertical Axis
@export var XAxis_Rot_weigth : float = 7.0
#YAxis_Rot_weigth how fast camera rotates to look to MidPoint_PJ
@export var YAxis_Rot_weigth : float = 7.0
#ZAxis_Rot_weigth how fast camera tilts 
@export var ZAxis_Rot_weigth : float = 10.0
#POSITION
#Horizantal_Pos_weigth how fast camera to look to MidPoint_PJ onthe Vertical Axis
@export var Horizantal_Pos_weigth : float = 7.0
#Vertical_Pos_weigth how fast camera rotates to look to MidPoint_PJ
@export var Vertical_Pos_weigth : float = 10.0


####--INIT--####
func _ready() -> void:
	#Getter of the Initial Camera Position
	#Cam_Virtual_Direction = Vector2(Cam.global_position.x, Cam.global_position.z).normalized()
	Cam_Virtual_Direction = Vector2(0.0, 1.0)


func _physics_process(delta: float) -> void:
	#Updating variables
	PJ1_Pos = Vector2(PJ1.global_position.x, PJ1.global_position.z)
	PJ2_Pos = Vector2(PJ2.global_position.x, PJ2.global_position.z)
	PJ1_Vertical_Pos = PJ1.global_position.y
	PJ2_Vertical_Pos = PJ2.global_position.y
	
	MidPoint_PJ = (PJ1_Pos + PJ2_Pos) / 2
	Vector_PJ = Vector2(PJ1_Pos.x - PJ2_Pos.x, PJ1_Pos.y - PJ2_Pos.y).normalized()
	Perp_Vector_PJ = Vector2(-1 * Vector_PJ.y, Vector_PJ.x).normalized()
	Distance_PJ = PJ1_Pos.distance_to(PJ2_Pos)
	Diff_h = abs(PJ1_Vertical_Pos - PJ2_Vertical_Pos)
	
	#Getter of the Direction Vector and the angle to rotate
	perpendicular_vector_getter()
	
	#Final constructor of Camera's Position and Rotation
	camera_virtual_setter()
	
	#Interpolation done to move the Camera to the Virtual Position and rotation
	camera_rotpos_applying(delta)
	
	#Determine wich sides are PJs
	pjs_side()
	if (current_sides == "P1_P2"):
		FM.current_sidePJ1 = "LEFT"
		FM.current_sidePJ2 = "RIGHT"
	else:
		FM.current_sidePJ1 = "RIGHT"
		FM.current_sidePJ2 = "LEFT"
	
	

##--CUSTOM FUNCTIONS--##
func perpendicular_vector_getter():
	#This is to avoid a ZERO Vector, project() method doesn't accept ZERO Vectors
	if (Perp_Vector_PJ != Vector2.ZERO):
		pass
	else:
		Perp_Vector_PJ = Cam_Virtual_Direction
	
	##Scalar_Proj
	Scalar_Proj = Cam_Virtual_Direction.project(Perp_Vector_PJ)
	
	##Ang_Diff
	Ang_Diff = Cam_Virtual_Direction.angle_to(Scalar_Proj)
	Cam_YTarget_rot -= Ang_Diff
	
	##Updating Cam_Virtual_Direction
	Cam_Virtual_Direction = Perp_Vector_PJ
	

func camera_virtual_setter():
	#HORIZONTAL DISTANCE THRESHOLD
	if (Distance_PJ <= max_distance_threshold):
		#Rot
		Cam_Virtual_Rot.x = min_topdownview_deg
		Cam_Virtual_Rot.y = Cam_YTarget_rot
		Cam_Virtual_Rot.z = min_tilt_deg
		#Pos
		Cam_Virtual_Pos.x = (sin(Cam_Virtual_Rot.y) * min_cam_distance) + MidPoint_PJ.x
		Cam_Virtual_Pos.y = min_cam_height
		Cam_Virtual_Pos.z = (cos(Cam_Virtual_Rot.y) * min_cam_distance) + MidPoint_PJ.y
	else:
		#Rot
		Cam_Virtual_Rot.x = max_topdownview_deg
		Cam_Virtual_Rot.y = Cam_YTarget_rot
		Cam_Virtual_Rot.z = max_tilt_deg
		#Pos
		Cam_Virtual_Pos.x = (sin(Cam_Virtual_Rot.y) * max_cam_distance) + MidPoint_PJ.x
		Cam_Virtual_Pos.y = max_cam_height
		Cam_Virtual_Pos.z = (cos(Cam_Virtual_Rot.y) * max_cam_distance) + MidPoint_PJ.y
	

func pjs_side():
	CamtoCenter_vector = Vector3(Cam_Virtual_Pos.x-MidPoint_PJ.x, 0.0, Cam_Virtual_Pos.z-MidPoint_PJ.y).normalized()
	PJ1Cam_vector = Vector3(PJ1_Pos.x-MidPoint_PJ.x, 0.0, PJ1_Pos.y-MidPoint_PJ.y).normalized()
	
	PJ1_crossed = PJ1Cam_vector.cross(CamtoCenter_vector)
	
	if (PJ1_crossed.y >= 0.0):
		current_sides = "P1_P2"
	else:
		current_sides = "P2_P1"
	
	Sides_Label.set_deferred("text", current_sides)
	

func camera_rotpos_applying(delta):
	##Rot Interpolation
	Interpolated_Rot.x = lerp_angle(Cam.rotation.x, Cam_Virtual_Rot.x, delta * XAxis_Rot_weigth)
	Interpolated_Rot.y = lerp_angle(Cam.rotation.y, Cam_Virtual_Rot.y, delta * YAxis_Rot_weigth)
	Interpolated_Rot.z = lerp_angle(Cam.rotation.z, Cam_Virtual_Rot.z, delta * ZAxis_Rot_weigth)
	Cam.set_deferred("rotation", Interpolated_Rot)
	
	##Pos Interpolation
	Interpolated_Pos.x = lerp(Cam.global_position.x, Cam_Virtual_Pos.x, delta * Horizantal_Pos_weigth)
	Interpolated_Pos.y = lerp(Cam.global_position.y, Cam_Virtual_Pos.y, delta * Vertical_Pos_weigth)
	Interpolated_Pos.z = lerp(Cam.global_position.z, Cam_Virtual_Pos.z, delta * Horizantal_Pos_weigth)
	Cam.set_deferred("global_position", Interpolated_Pos)
	
