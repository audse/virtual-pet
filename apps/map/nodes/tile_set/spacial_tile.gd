class_name SpacialTile
extends MeshInstance3D
@icon("spacial_tile_icon.svg")

## Defines a unique ID string used to find this tile
@export var id: String

## Defines the bits (of 2D bitmask) that are "filled in" for this tile
@export var top_left: bool
@export var top_right: bool
@export var bottom_left: bool
@export var bottom_right: bool

## Defines groups of vertices that will be used for deformations
@export var vertex_data: Resource


func get_bitmask() -> BitMask:
	var bitmask := BitMask.new()
	bitmask.top_left = top_left
	bitmask.top_right = top_right
	bitmask.bottom_left = bottom_left
	bitmask.bottom_right = bottom_right
	return bitmask


func enter() -> void:
	scale.y = 0.0
	scale.x = 1.5
	scale.z = 1.5
	position.y = -0.2
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(self, "position:y", 0.0, 0.5)
	tween.tween_property(self, "scale:y", 1.0, 0.75)
	tween.tween_property(self, "scale:x", 1.0, 0.75)
	tween.tween_property(self, "scale:z", 1.0, 0.75)


func exit() -> void:
	await get_tree().create_timer(0.25).timeout
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale:x", 0.75, 0.2)
	tween.tween_property(self, "scale:z", 0.75, 0.2)
	tween.tween_property(self, "scale:y", 0.25, 0.5)
	tween.parallel().tween_property(self, "scale:x", 0.5, 0.5)
	tween.parallel().tween_property(self, "scale:z", 0.5, 0.5)
	tween.tween_callback(queue_free)


func load_surfaces_mesh_data() -> Dictionary: # { surface_index: MeshDataToolPlus, .. }
	var all_data: Dictionary = {}
	
	for surface in range(mesh.get_surface_count()):
		var surface_data := MeshDataToolPlus.new()
		surface_data.create_from_surface(mesh, surface)
		vertex_data.load_data(surface_data, surface)
		all_data[surface] = surface_data
	
	return all_data


func get_surface_overrides() -> Array[Material]:
	var overrides: Array[Material] = []
	for surface in range(get_surface_override_material_count()):
		overrides.append(get_surface_override_material(surface))
	return overrides


func distort_all(offset: Vector3) -> void:
	var surfaces := load_surfaces_mesh_data()
	
	# save mesh data to replace
	var new_mesh := mesh.duplicate()
	var overrides := get_surface_overrides()
	new_mesh.clear_surfaces()
	
	# only generate distort random once, so that all surfaces match
	var distort_rand: bool = Utils.Random.randi_range(0, 1) == 1
	
	# each surface has its own groups that need to be distorted
	for surface in surfaces.keys():
		# skip if no groups exist
		if not surface in vertex_data.groups: continue
		
		var surface_data: MeshDataToolPlus = surfaces[surface]
		var groups: Array[VertexGroup] = vertex_data.groups[surface]
		
		for group in groups:
			distort_group(group, offset, distort_rand)
		
		commit_to_surface(surface_data, new_mesh, groups)
	
	mesh = new_mesh
	
	# add back the original surface overrides
	for surface in range(len(overrides)):
		if overrides[surface]: set_surface_override_material(surface, overrides[surface])


func distort_group(group: VertexGroup, offset: Vector3, distort_rand: bool) -> void:
	if "corner" in group.group_name and not "inner_corner" in group.group_name:
		group.move_all_by(offset)
	
	elif "center_edge" in group.group_name and distort_rand:
		group.move_all_by(offset / 4)


func commit_to_surface(surface_data: MeshDataToolPlus, surface_mesh: Mesh, groups: Array) -> void:
	for group in groups:
		for vertex in group.vertices:
			for mesh_index in vertex.mesh_indices:
				surface_data.set_vertex(mesh_index, vertex.position)
	
	surface_data.commit_to_surface(surface_mesh)
