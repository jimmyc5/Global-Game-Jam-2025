extends Node3D

@onready var canvas: CanvasLayer = %"CanvasLayer"
@onready var music: CheckBox = %"Music"
@onready var sfx: CheckBox = %"SFX"

var is_paused = false
var can_pause = true

func _ready() -> void:
	canvas.visible = false
	if Globals.music_disabled:
		music.button_pressed = true
	if Globals.sfx_disabled:
		sfx.button_pressed = true
	Globals.connect("bathtub_entered", disable_pause)

func disable_pause():
	can_pause = false

func _process(_delta: float) -> void:
	if can_pause and Input.is_action_just_pressed("pause"):
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
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
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


func _on_continue_mouse_entered() -> void:
	Globals.play_pop_sound()


func _on_restart_mouse_entered() -> void:
	Globals.play_pop_sound()


func _on_mainmenu_mouse_entered() -> void:
	Globals.play_pop_sound()


func _on_music_toggled(toggled_on: bool) -> void:
	Globals.toggle_music(toggled_on)


func _on_sfx_toggled(toggled_on: bool) -> void:
	Globals.toggle_sfx(toggled_on)


func _on_music_mouse_entered() -> void:
	Globals.play_pop_sound()


func _on_sfx_mouse_entered() -> void:
	Globals.play_pop_sound()
