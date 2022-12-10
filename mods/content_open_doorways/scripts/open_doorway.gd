extends WorldObjectMeshInstance

var nav_region := NavigationRegion3D.new()
var nav_mesh := MeshInstance3D.new()

var item_data: ItemData:
	get: return context.object_data.item_data

@onready var thread := Thread.new()


func _enter_tree() -> void:
	nav_region.navmesh = NavigationMesh.new()
	nav_region.navmesh.agent_radius = 0.01
	nav_region.navmesh.agent_height = 0.5
	add_child(nav_region)
	nav_region.add_child(nav_mesh)


func _ready() -> void:	
	if context: _on_context_changed()


func _exit_tree() -> void:
	thread.wait_to_finish()


func _on_context_changed() -> void:
	thread.start(bake_nav_mesh)


func bake_nav_mesh() -> void:
	if item_data and item_data.building_data:
		var intersection_rect: Rect2 = item_data.building_data.intersection_rect
		var aabb := mesh.get_aabb()
		
		# shrink to fit within intersected rect
		aabb = aabb.grow((aabb.size.x - intersection_rect.size.x) * -0.5)
		
		# expand to depth of entire tile
		aabb = aabb.expand(Vector3(item_data.physical_data.dimensions.x as float / 2.0, 0.0, item_data.physical_data.dimensions.z))
		aabb = aabb.expand(Vector3(item_data.physical_data.dimensions.x as float / 2.0, 0.0, -item_data.physical_data.dimensions.z))
		
		# shrink to floor
		aabb.size.y = 0.01
	#
		nav_mesh.position = aabb.position + aabb.size / 2
		nav_mesh.position.y = 0.0
		
		var box_mesh := BoxMesh.new()
		box_mesh.size = aabb.size
		nav_mesh.mesh = box_mesh
		nav_mesh.visible = false
		
	#	nav_mesh.mesh = mesh
		nav_region.bake_navigation_mesh()
		await nav_region.bake_finished
