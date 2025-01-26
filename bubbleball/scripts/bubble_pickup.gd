extends Area3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D

const bubble_mats = [
	preload("res://assets/material/bubble_material.tres"),
	preload("res://assets/material/bubble_material_0.tres"),
	preload("res://assets/material/bubble_material_01.tres")
]

func _ready():
	var rand_scale = randf_range(0.6, 1.2)
	scale = Vector3(rand_scale, rand_scale, rand_scale)
	var index = randi() % bubble_mats.size()
	mesh_instance_3d.material_override = bubble_mats[index]

func _on_body_entered(body: Node3D) -> void:
	Globals.bubble_picked_up()
	collision_shape_3d.reparent(body);
	mesh_instance_3d.reparent(body);
	shape_cast_3d.reparent(body.get_parent());
	queue_free();
