extends ShapeCast3D
@export var followHitbox: CollisionShape3D



func _physics_process(delta: float) -> void:
	global_position = followHitbox.global_position
