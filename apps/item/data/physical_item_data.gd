class_name PhysicalItemData
extends Resource

@export var mesh: Mesh
@export var dimensions: Vector3i
@export var world_layer: int

@export_subgroup("Optional world data")
@export var mesh_scale := Vector3.ONE
@export var collision_shape: Shape3D = null
@export var mesh_script: Script
@export var stackable: bool = false
@export var walkable: bool = false

var area: int:
	get: return dimensions.x * dimensions.z

var used_coords: Array[Vector2i]:
	get:
		var coords: Array[Vector2i] = []
		for x in dimensions.x: for y in dimensions.z:
			coords.append(Vector2i(x, y))
		return coords


func _init(args := {}) -> void:
	for key in args.keys(): if key in self: self[key] = args[key]


func render_mesh(parent: Node) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	if mesh_script: mesh_instance.set_script(mesh_script)
	mesh_instance.mesh = mesh
	mesh_instance.scale = mesh_scale
	parent.add_child(mesh_instance)
	return mesh_instance
 

func render(parent: Node, create_approx_collision := false) -> Dictionary:
	var mesh_instance := render_mesh(parent)
	
	if not create_approx_collision:
		if not stackable: mesh_instance.create_trimesh_collision()
	else:
		var box := BoxMesh.new()
		box.size = Vector3(dimensions)
		mesh_instance.mesh = box
		mesh_instance.create_trimesh_collision()
		mesh_instance.mesh  = mesh
	
	var collision := Utils.first_child_of_type(mesh_instance, "CollisionShape3D")
	if collision:
		collision.get_parent().remove_child(collision)
		parent.add_child(collision)
	
	return {
		mesh_instance = mesh_instance,
		collision_instance = collision,
	}
