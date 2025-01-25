extends Area3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	Globals.bubble_picked_up()
	collision_shape_3d.reparent(body);
	mesh_instance_3d.reparent(body);
	shape_cast_3d.reparent(body.get_parent());
	queue_free();
