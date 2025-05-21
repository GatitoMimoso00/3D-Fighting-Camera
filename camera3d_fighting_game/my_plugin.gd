@tool
extends EditorPlugin

##HERE WE LOAD CLASSES##

const CAMERA3D : GDScript = preload("res://addons/camera3d_fighting_game/Camera3DFighting.gd")

func _enter_tree() -> void:
	add_custom_type("MiCamera", "Camera3D", CAMERA3D, null)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
