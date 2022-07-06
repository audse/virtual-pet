extends MeshInstance3D

const SIZE := Vector3(2.1, 0.15, 2.1)
const Y_POS := SIZE.y / 2

var building_material: StandardMaterial3D = Assets.import(Assets.materials.building_guide)


func _init() -> void:
	mesh = BoxMesh.new()
	mesh.size = SIZE
	position.y = Y_POS
	mesh.material = building_material
