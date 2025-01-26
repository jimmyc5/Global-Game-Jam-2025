extends Node3D

@onready var water: MeshInstance3D = %"water"
@onready var bubbles: GPUParticles3D = %"BUBBLES"

var first_entered: bool = false

var initial_water_color: Color = Color(0.337, 0.386, 0.696, 1)
var win_water_color: Color = Color(0.752, 0.5, 0.7, 1)

func _ready():
	bubbles.emitting = false
	water.material_override.set_shader_parameter("color", initial_water_color)

func _on_area_3d_body_entered(_body: Node3D) -> void:
	if not first_entered:
		first_entered = true
		play_pop_sounds()
		water.material_override.set_shader_parameter("color", win_water_color)
		bubbles.emitting = true
		Globals.emit_signal("bathtub_entered")

func play_pop_sounds():
	Globals.play_pop_sound()
	var tree = get_tree()
	if tree:
		tree.create_timer(0.08, false).timeout.connect(play_pop_sounds)
