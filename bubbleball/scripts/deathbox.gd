extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	Globals.emit_signal("player_died")
	call_deferred("reload_scene")

func reload_scene():
	get_tree().reload_current_scene()
