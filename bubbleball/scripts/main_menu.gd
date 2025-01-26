extends Node3D

const MAIN_THEME: AudioStream = preload("res://assets/audio/overworld-melody.mp3")
const GAME_THEME: AudioStream = preload("res://assets/audio/pixify.mp3")

@export var letter_texts: Array[Control]

func _ready():
	Globals.toggle_speed_mode(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	AudioPlayer.play_music(MAIN_THEME)
	var letter_delay = 0.08
	for i in range(letter_texts.size()):
		var tween = get_tree().create_tween()
		letter_texts[i].scale = Vector2(0, 0)
		tween.tween_property(
			letter_texts[i],
			"scale",
			Vector2(1, 1),
			letter_delay
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE).set_delay(i * letter_delay)
		tween.finished.connect(play_pop_sound)

func play_pop_sound():
	Globals.play_pop_sound("Master")

func _on_button_button_down() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	AudioPlayer.play_music(GAME_THEME)
	Globals.toggle_speed_mode(false)
	get_tree().change_scene_to_file("res://scenes/levels/level_" + str(Globals.level_number) + ".tscn")


func _on_button_mouse_entered() -> void:
	Globals.play_pop_sound()
