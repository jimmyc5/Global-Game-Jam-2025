extends Node3D

@onready var level_text: RichTextLabel = %"level_count"
@onready var level_text_1: RichTextLabel = %"level_count2"
@onready var bubble_text: RichTextLabel = %"bubble_count"
@onready var bubble_text_1: RichTextLabel = %"bubble_count2"
@onready var timer_text: RichTextLabel = %"timer"
@onready var timer_text_1: RichTextLabel = %"timer2"
@onready var black_screen: ColorRect = %"BlackScreen"
@onready var timer_text_red: RichTextLabel = %"timer_red"
@onready var timeout = %"timeout"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	black_screen.modulate.a = 1
	black_screen.visible = true
	set_level_text()
	set_timer_text()
	set_bubble_text()
	fade_screen_out()
	
	Globals.connect("fade_screen_in", fade_screen_in)
	Globals.connect("fade_screen_out", fade_screen_out)
	Globals.connect("set_level_text", set_level_text)
	Globals.connect("bubble_added", set_bubble_text)
	Globals.connect("set_timer_text", set_timer_text)
	
	toggle_red_text(false)
	timeout.visible = false

func toggle_red_text(on: bool):
	if on:
		timer_text_red.visible = true
		timer_text_1.visible = false
	else:
		timer_text_red.visible = false
		timer_text_1.visible = true

func set_level_text():
	level_text.text = " " + str(Globals.level_number)
	level_text_1.text = " " + str(Globals.level_number)

func set_bubble_text():
	var bubbles_left = Globals.bubble_count - Globals.bubbles_collected
	bubble_text.text = " " + str(bubbles_left)
	bubble_text_1.text = " " + str(bubbles_left)

func set_timer_text():
	timer_text.text = " " + str(Globals.time_limit)
	timer_text_1.text = " " + str(Globals.time_limit)
	timer_text_red.text = " " + str(Globals.time_limit)
	if Globals.time_limit <= 10:
		toggle_red_text(true)
	if Globals.time_limit <= 0:
		Globals.emit_signal("stop_player")
		timeout.scale = Vector2.ZERO
		timeout.visible = true
		var tween = get_tree().create_tween()
		tween.tween_property(
			timeout,
			"scale",
			Vector2(1, 1),
			1
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.finished.connect(disable_black_screen)

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

func fade_screen_in(duration: float = 1.5, delay: float = 0):
	black_screen.visible = true
	black_screen.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(
		black_screen,
		"modulate:a",
		1,
		duration
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT).set_delay(delay)
