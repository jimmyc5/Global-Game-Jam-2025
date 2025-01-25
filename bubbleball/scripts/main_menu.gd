extends Node3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_button_button_down() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	get_tree().change_scene_to_file("res://scenes/levels/level_" + str(Globals.level_number) + ".tscn")
