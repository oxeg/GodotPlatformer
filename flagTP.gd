extends Node3D

signal captured
@export_file("*.tscn") var load_scene: String

func _on_area_3d_body_entered(body):
	# Wait a bit to allow the player to "land" on the flag
	await get_tree().create_timer(0.15).timeout

	# Fly up for half a second
	body.gravity = -100
	captured.emit()
	await get_tree().create_timer(0.5).timeout

	if load_scene and get_tree():
		get_tree().change_scene_to_file(load_scene)
