extends Node3D

# make sure to set this bubble count in each level
@export var bubble_count: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.set_bubbles(bubble_count)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
