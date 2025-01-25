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

var lastTimeOnFloor := 0
var lastJumpInputTime := 0

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var tilt_upper_limit := PI / 3.0
@export var tilt_lower_limit := -PI / 8.0

var move_vector: Vector3 = Vector3.ZERO
var _camera_input_direction := Vector2.ZERO
var _gravity := -30.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func get_input():
	move_vector = Vector3.ZERO

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_input()
	#bubble.apply_central_force(move_vector * move_speed)
	#camera.position = bubble.position + camera_offset
	
func is_on_floor():
	var casts = find_children("*", "ShapeCast3D", false, false)
	for cast in casts:
		cast.force_shapecast_update();
		if cast.get_collision_count() > 0:
			return true
	return false
	
func _physics_process(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, tilt_lower_limit, tilt_upper_limit)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta

	_camera_input_direction = Vector2.ZERO

	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	var y_velocity := bubble.linear_velocity.y
	var xz_velocity := bubble.linear_velocity;
	xz_velocity.y = 0;
	var newVelocity = xz_velocity.move_toward(move_direction * move_speed, acceleration * delta)
	newVelocity.y = y_velocity #+ _gravity * delta
	var computedVelocity = (newVelocity - bubble.linear_velocity) * bubble.mass / delta
	bubble.apply_central_force(computedVelocity)
	bubble.apply_torque(Vector3(0,1,0).cross(computedVelocity) / 4)

	# handle jumping
	
	var currentTime = Time.get_ticks_msec()#

	if is_on_floor():
		lastTimeOnFloor = currentTime

	if Input.is_action_just_pressed("jump"):
		lastJumpInputTime = currentTime
		
	if currentTime < lastJumpInputTime + jump_buffer && currentTime < lastTimeOnFloor + coyote_time:
		bubble.apply_central_impulse(Vector3(0, -bubble.linear_velocity.y + jump_impulse, 0))
		lastJumpInputTime = currentTime - jump_buffer
	
		
		
	
