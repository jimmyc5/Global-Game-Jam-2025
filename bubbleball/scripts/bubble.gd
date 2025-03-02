extends Node3D

@onready var bubble: RigidBody3D = %"Bubble"
@onready var _camera: Camera3D = %"Camera"
@onready var _camera_pivot: Node3D = %CameraPivot


@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var jump_impulse := 6.0
@export var jump_buffer := 300
@export var coyote_time := 200
@export var nuetral_stick_influence := 0.2

var lastTimeOnFloor := 0
var lastJumpInputTime := 0

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var tilt_upper_limit := PI / 3.0
@export var tilt_lower_limit := -PI / 8.0

var initializing: bool = true

var move_vector: Vector3 = Vector3.ZERO
var _camera_input_direction := Vector2.ZERO
var _gravity := -30.0

var currentBubbleCount = 1;
var in_da_tub: bool = false

func _input(event: InputEvent) -> void:
	if not initializing and event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if initializing:
		return
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.connect("stop_player", stop_player)
	Globals.connect("bathtub_entered", rub_a_dub_dub)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var transition_time = 3
	var tween = get_tree().create_tween()
	var rotation_y
	if randi_range(0, 1):
		rotation_y = 3.25
	else:
		rotation_y = -3.25
	tween.tween_property(
		_camera_pivot,
		"rotation:y",
		rotation_y,
		transition_time
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	tween.parallel().tween_property(
		_camera_pivot,
		"rotation:x",
		0.5,
		transition_time
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	tween.finished.connect(done_initializing)

func stop_player():
	print("freezing")
	bubble.freeze = true

func rub_a_dub_dub():
	initializing = true
	in_da_tub = true
	bubble.sleeping = true
	bubble.visible = false

func done_initializing():
	initializing = false
	Globals.emit_signal("player_ready")

func get_input():
	move_vector = Vector3.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if initializing:
		return
	get_input()
	#bubble.apply_central_force(move_vector * move_speed)
	#camera.position = bubble.position + camera_offset
	
func is_on_floor():
	var casts = find_children("*", "ShapeCast3D", false, false)
	currentBubbleCount = casts.size();
	for cast in casts:
		cast.force_shapecast_update();
		if cast.get_collision_count() > 0:
			return true
	return false

func get_camera_rotation(delta):
	if not initializing:
		var look_direction = Vector2.ZERO;
		if Input.is_action_pressed("look_left"):
			look_direction += Vector2(-1, 0);
		if Input.is_action_pressed("look_right"):
			look_direction += Vector2(1, 0);
		if Input.is_action_pressed("look_up"):
			look_direction += Vector2(0, -1);
		if Input.is_action_pressed("look_down"):
			look_direction += Vector2(0, 1);
		if look_direction:
			_camera_input_direction = look_direction * 3
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, tilt_lower_limit, tilt_upper_limit)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta


func _physics_process(delta: float) -> void:
	get_camera_rotation(delta)

	_camera_input_direction = Vector2.ZERO
	
	if initializing:
		return

	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	
	var accelerationMultiplier = 1

	if not move_direction:
		accelerationMultiplier = nuetral_stick_influence;
	
	var y_velocity := bubble.linear_velocity.y
	var xz_velocity := bubble.linear_velocity;
	xz_velocity.y = 0;
	var newVelocity = xz_velocity.move_toward(move_direction * move_speed, acceleration * delta * accelerationMultiplier)
	newVelocity.y = y_velocity #+ _gravity * delta
	var computedVelocity = (newVelocity - bubble.linear_velocity) * bubble.mass / delta
	bubble.apply_central_force(computedVelocity)
	#bubble.apply_torque(Vector3(0,1,0).cross(computedVelocity) / 4)

	# handle jumping
	
	var currentTime = Time.get_ticks_msec()#

	if is_on_floor():
		lastTimeOnFloor = currentTime

	if Input.is_action_just_pressed("jump"):
		lastJumpInputTime = currentTime
		
	if currentTime < lastJumpInputTime + jump_buffer && currentTime < lastTimeOnFloor + coyote_time:
		if bubble.linear_velocity.y < 0:
			bubble.apply_central_impulse(Vector3(0, -bubble.linear_velocity.y + jump_impulse, 0))
		else:
			bubble.apply_central_impulse(Vector3(0, jump_impulse, 0))
		lastJumpInputTime = currentTime - jump_buffer
