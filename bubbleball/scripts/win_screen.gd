extends Node3D

@onready var black_screen: ColorRect = %"BlackScreen"
@onready var thanks = %"thanks"

var thanks_pos

const EPIC_BATTLE: AudioStream = preload("res://assets/audio/epic-battle.mp3")

func _ready():
	black_screen.visible = true
	black_screen.modulate.a = 1
	thanks_pos = thanks.position
	fade_screen_out()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	AudioPlayer.play_music(EPIC_BATTLE)
	thanks_up()

func _on_button_button_down() -> void:
	Globals.level_number = 0
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_button_mouse_entered() -> void:
	Globals.play_pop_sound()

func fade_screen_out(duration: float = 1.5, delay: float = 0):
	black_screen.visible = true
	black_screen.modulate.a = 1
	var tween = get_tree().create_tween()
	tween.tween_property(
		black_screen,
		"modulate:a",
		0,
		duration
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT).set_delay(delay)
	tween.finished.connect(disable_black_screen)

func disable_black_screen():
	black_screen.visible = false

func thanks_up():
	var tween = get_tree().create_tween()
	tween.tween_property(
		thanks,
		"position",
		thanks_pos + Vector2(0, 5),
		1
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.finished.connect(thanks_down)

func thanks_down():
	var tween = get_tree().create_tween()
	tween.tween_property(
		thanks,
		"position",
		thanks_pos - Vector2(0, 5),
		1
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.finished.connect(thanks_up)
