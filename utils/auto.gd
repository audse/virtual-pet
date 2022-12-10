extends Node


var Random = RandomNumberGenerator.new()

func _ready() -> void:
	Random.randomize()


func get_screen_center_in_world() -> Vector3:
	var viewport := get_viewport()
	if not viewport: return Vector3.ZERO
	
	var camera := viewport.get_camera_3d()
	if not camera: return Vector3.ZERO
	
	return Vector3Ref.project_position_to_floor(
		camera,
		viewport.get_visible_rect().size / 2
	)
	
