extends MeshInstance3D

const SIZE := Vector3(1.0, 0.1, 1.0)
const Y_POS := SIZE.y + 0.25

var building_material: StandardMaterial3D: 
	get: 
		var mat := Assets.import(Assets.materials.building_guide)
		if not is_buildable: 
			mat = mat.duplicate()
			mat.albedo_color = Color("#f43f5e")
		return mat

var is_buildable: bool:
	get: return BuildData.is_area_buildable([coord])

var coord: Vector3i

func _init(coord_value: Vector3i) -> void:
	coord = coord_value
	mesh = BoxMesh.new()
	mesh.size = SIZE
	position.y = Y_POS
	mesh.material = building_material
