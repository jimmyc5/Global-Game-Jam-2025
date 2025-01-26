extends Node3D

# make sure to set this bubble count in each level
@export var bubble_count: int = 0
@export var time_limit: int = 30

var playing = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.set_bubbles(bubble_count)
	Globals.time_limit = time_limit
	Globals.emit_signal("set_timer_text")
	Globals.connect("player_ready", initiate_timer)
	Globals.connect("bathtub_entered", stop_timer)
	Globals.toggle_speed_mode(false)

func initiate_timer():
	set_timer(time_limit)

func stop_timer():
	playing = false

func set_timer(time_amount):
	if playing:
		Globals.time_limit = time_amount
		Globals.emit_signal("set_timer_text")
		var timer = get_tree().create_timer(1, false)
		timer.timeout.connect(reset_timer)

func reset_timer():
	var new_limit = Globals.time_limit - 1
	if new_limit <= 10:
		Globals.toggle_speed_mode(true)
	if new_limit < 0:
		Globals.player_died()
	else:
		set_timer(new_limit)
