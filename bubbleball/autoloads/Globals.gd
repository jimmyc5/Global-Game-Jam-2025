extends Node

signal bathtub_entered
signal bubble_added
signal fade_screen_out
signal fade_screen_in
signal set_level_text
signal set_timer_text
signal player_ready

var level_number: int = 0
var max_level: int = 10

# gets set and tracked in level_base.gd
var bubble_count: int = 0
var bubbles_collected: int = 0
var time_limit: int = 0
var level_initialized = false

func _ready():
	connect("bathtub_entered", next_level)

func set_bubbles(num_bubbs):
	bubble_count = num_bubbs
	bubbles_collected = 0
	emit_signal("bubble_added")

func bubble_picked_up():
	bubbles_collected += 1
	emit_signal("bubble_added")

func player_died():
	emit_signal
	call_deferred("reload_scene")

func reload_scene():
	get_tree().reload_current_scene()	

func next_level():
	var _next_level = level_number + 1
	if _next_level >= max_level:
		win_game()
	else:
		level_number = _next_level
		level_initialized = false
		var fade_duration = 4
		var delay = 2
		emit_signal("fade_screen_in", fade_duration, delay)
		var timer = get_tree().create_timer(fade_duration + delay, false)
		timer.timeout.connect(set_next_level)

func set_next_level():
	emit_signal("set_level_text")
	get_tree().change_scene_to_file("res://scenes/levels/level_" + str(level_number) + ".tscn")


func win_game():
	pass
