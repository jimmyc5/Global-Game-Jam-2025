extends Node3D

@onready var water: MeshInstance3D = %"water"
@onready var bubbles: GPUParticles3D = %"BUBBLES"

var initial_water_color: Color = Color(0.337, 0.386, 0.696, 1)
var win_water_color: Color = Color(0.752, 0.5, 0.7, 1)

func _ready():
	bubbles.emitting = false
	water.material_override.set_shader_parameter("color", initial_water_color)

func _on_area_3d_body_entered(_body: Node3D) -> void:
	water.material_override.set_shader_parameter("color", win_water_color)
	bubbles.emitting = true
	Globals.emit_signal("bathtub_entered")
