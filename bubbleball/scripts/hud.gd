extends Node3D

@onready var level_text: RichTextLabel = %"level_count"
@onready var level_text_1: RichTextLabel = %"level_count2"
@onready var black_screen: ColorRect = %"BlackScreen"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	black_screen.modulate.a = 1
	black_screen.visible = true
	set_level_text()
	fade_screen_out()
	
	Globals.connect("fade_screen_in", fade_screen_in)
	Globals.connect("fade_screen_out", fade_screen_out)
	Globals.connect("set_level_text", set_level_text)

func set_level_text():
	level_text.text = " " + str(Globals.level_number)
	level_text_1.text = " " + str(Globals.level_number)

func fade_screen_out(duration: float = 1):
	var tween = get_tree().create_tween()
	tween.tween_property(
		black_screen,
		"modulate:a",
		0,
		duration
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.finished.connect(disable_black_screen)

func disable_black_screen():
	black_screen.visible = false

func fade_screen_in(duration: float = 1.5):
	black_screen.visible = true
	black_screen.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(
		black_screen,
		"modulate:a",
		1,
		duration
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
