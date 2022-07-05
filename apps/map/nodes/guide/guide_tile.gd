extends MeshInstance3D

const size := Vector3(2.1, 0.15, 2.1)
const y_position := size.y / 2

var building_material: StandardMaterial3D = Assets.import(Assets.materials.building_guide)


func _ready() -> void:
	mesh = BoxMesh.new()
	mesh.size = size
	position.y = y_position
	mesh.material = building_material
