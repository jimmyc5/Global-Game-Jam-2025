extends Node3D

@onready var canvas: CanvasLayer = %"CanvasLayer"

var is_paused = false

func _ready() -> void:
	canvas.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if is_paused:
			unpause_game()
		else:
			pause_game()

func pause_game():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	is_paused = true
	canvas.visible = true
	get_tree().paused = true

func unpause_game():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	get_tree().paused = false
	canvas.visible = false
	is_paused = false

func _on_mainmenu_button_down() -> void:
	unpause_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_restart_button_down() -> void:
	unpause_game()
	get_tree().reload_current_scene()


func _on_continue_button_down() -> void:
	unpause_game()
