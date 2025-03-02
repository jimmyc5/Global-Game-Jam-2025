extends Node

signal bathtub_entered
signal bubble_added
signal fade_screen_out
signal fade_screen_in
signal set_level_text
signal set_timer_text
signal player_ready
signal stop_player

const POP_EFFECTS: Array[AudioStream] = [
	preload("res://assets/audio/pop_0.wav"),
	preload("res://assets/audio/pop_1.wav"),
	preload("res://assets/audio/pop_2.wav"),
	preload("res://assets/audio/pop_3.wav"),
	preload("res://assets/audio/pop_4.wav"),
	preload("res://assets/audio/pop_5.wav")
]

func play_pop_sound(bus = "Effects"):
	var index = randi() % POP_EFFECTS.size()
	AudioPlayer.play_effect(POP_EFFECTS[index], 0.0, randf_range(0.8, 1.3), 0, bus)

var level_number: int = 0
var max_level: int = 8

var music_disabled: bool = false
var sfx_disabled: bool = false

# gets set and tracked in level_base.gd
var bubble_count: int = 0
var bubbles_collected: int = 0
var time_limit: int = 0
var level_initialized = false

func _ready():
	connect("bathtub_entered", next_level)

func toggle_speed_mode(on: bool):
	var index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_effect_enabled(index, 0, on)
	AudioServer.set_bus_effect_enabled(index, 1, on)
	AudioServer.set_bus_effect_enabled(index, 2, on)

func toggle_music(toggle: bool):
	var index = AudioServer.get_bus_index("Music")
	music_disabled = toggle
	AudioServer.set_bus_mute(index, toggle)
	

func toggle_sfx(toggle: bool):
	var index = AudioServer.get_bus_index("Effects")
	sfx_disabled = toggle
	AudioServer.set_bus_mute(index, toggle)

func set_bubbles(num_bubbs):
	bubble_count = num_bubbs
	bubbles_collected = 0
	emit_signal("bubble_added")

func bubble_picked_up():
	bubbles_collected += 1
	play_pop_sound()
	emit_signal("bubble_added")

func player_died():
	emit_signal("stop_player")
	play_pop_sound()
	var fade_duration = 1
	emit_signal("fade_screen_in", fade_duration)
	var timer = get_tree().create_timer(fade_duration)
	timer.timeout.connect(reload_scene)

func reload_scene():
	get_tree().reload_current_scene()	

func next_level():
	print("starting level: " + str(level_number + 1))
	var _next_level = level_number + 1
	toggle_speed_mode(false)
	if _next_level > max_level:
		var fade_duration = 4
		var delay = 2
		emit_signal("fade_screen_in", fade_duration, delay)
		var timer = get_tree().create_timer(fade_duration + delay, false)
		timer.timeout.connect(win_game)
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
	call_deferred("_win_game")

func _win_game():
	get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
