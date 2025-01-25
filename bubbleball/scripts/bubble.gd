extends RigidBody3D

var move_vector: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func get_input():
	move_vector = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		move_vector += Vector3(0, 0, -1)
	if Input.is_action_pressed("move_backward"):
		move_vector += Vector3(0, 0, 1)
	if Input.is_action_pressed("move_left"):
		move_vector += Vector3(-1, 0, 0)
	if Input.is_action_pressed("move_right"):
		move_vector += Vector3(1, 0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_input()
	print(move_vector)
	apply_central_force(move_vector)
