extends Node

signal bathtub_entered
signal player_died
signal bubble_added
signal fade_screen_out
signal fade_screen_in
signal set_level_text

var level_number: int = 0
var max_level: int = 10

# gets set and tracked in level_base.gd
var bubble_count: int = 0
var bubbles_collected: int = 0

func _ready():
	connect("bathtub_entered", next_level)

func set_bubbles(num_bubbs):
	bubble_count = num_bubbs
	bubbles_collected = 0
	emit_signal("bubble_added")

func bubble_picked_up():
	bubbles_collected += 1
	emit_signal("bubble_added")

func next_level():
	var next_level = level_number + 1
	if next_level >= max_level:
		win_game()
	else:
		level_number = next_level
		var fade_duration = 1.5
		emit_signal("fade_screen_in", fade_duration)
		var timer = get_tree().create_timer(fade_duration, false)
		timer.timeout.connect(set_next_level)

func set_next_level():
	emit_signal("set_level_text")
	get_tree().change_scene_to_file("res://scenes/levels/level_" + str(level_number) + ".tscn")


func win_game():
	pass
