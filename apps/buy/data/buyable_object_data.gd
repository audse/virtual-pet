class_name BuyableObjectData
extends Resource

enum Flag {
	OWNABLE,
	CONSUMABLE,
}

@export_group("Object identity")
@export var id: String
@export var display_name: String

@export_subgroup("Optional identity data")
@export var category_id: String = "uncategorized"
@export var description: String = ""
@export var colorway_id: String = ""

@export_group("World data")
@export var mesh: Mesh
@export var dimensions: Vector3i
@export var world_layer: WorldObjectData.Layer

@export_subgroup("Optional world data")
@export var mesh_scale := Vector3.ONE
@export var rarity := 0
@export var collision_shape: Shape3D = null
@export var consumed_meshes: Array[Mesh] = []

@export_group("Use data")
@export var flags: Array[Flag] = []
@export var fulfills_needs: Array[NeedsData.Need] = []
@export var actions: Array[String] = []
@export var total_uses: int = -1 # infinite


func _init(args := {}) -> void:
	for key in args.keys():
		if key in self: self[key] = args[key]


func render_mesh(parent: Node) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	parent.add_child(mesh_instance)
	mesh_instance.mesh = mesh
	mesh_instance.scale = mesh_scale
	mesh_instance.material_override = mesh_instance.mesh.surface_get_material(0).duplicate()
	(mesh_instance.material_override as BaseMaterial3D).cull_mode = BaseMaterial3D.CULL_DISABLED
	return mesh_instance


func render_collision(parent: Node) -> CollisionShape3D:
	var collision_instance := CollisionShape3D.new()
	parent.add_child(collision_instance)
	if collision_shape: collision_instance.shape = collision_shape
	else: collision_instance.make_convex_from_siblings()
	collision_instance.scale = mesh_scale
	return collision_instance


func render(parent: Node) -> void:
	render_mesh(parent)
	render_collision(parent)
