@tool
extends EditorPlugin

##HERE WE LOAD CLASSES##

const CAMERA3D : GDScript = preload("res://addons/camera3d_fighting_game/Camera3DFighting.gd")
const ICON : Texture2D = preload("C:/Users/joako/Godot Projects/3dfightingcamera/addons/camera3d_fighting_game/icon.svg")

func _enter_tree() -> void:
	add_custom_type("Camera3DFighting", "Camera3D", CAMERA3D, ICON)
	

func _exit_tree() -> void:
	remove_custom_type("Camera3DFighting")
	
