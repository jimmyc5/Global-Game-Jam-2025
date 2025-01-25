extends RigidBody3D

@export var rotate_speed = 0.05

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation.y += delta * rotate_speed
