extends Node

@onready var nav_region := %NavigationRegion3D as NavigationRegion3D
@onready var walkable_mesh := %WalkableMesh as MeshInstance3D


func _ready() -> void:
	NavigationServer3D.map_set_edge_connection_margin(nav_region.get_world_3d().get_navigation_map(), 1.5)
	bake_nav_region()
	
	Game.Mode.enter_state.connect(
		func(state) -> void:
			if state == GameModeState.Mode.LIVE: bake_nav_region()
	)


func bake_nav_region() -> void:
	var occupiable_coords: Array[Vector3i] = WorldData.blocks.values() \
		.filter(func(block: WorldBlockData) -> bool: return block.is_occupiable_by_pet()) \
		.map(func(block: WorldBlockData) -> Vector3i: return block.coord)
	
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3.UP)
	surface.set_uv(Vector2.ZERO)
	
	var unit: float = WorldData.grid_size
	for coord in occupiable_coords:
		var vert: Vector3 = WorldData.to_world(coord)
		surface.add_vertex(vert + Vector3(unit, 0, unit))
		surface.add_vertex(Vector3(vert.x, vert.y, vert.z + unit))
		surface.add_vertex(vert)
		surface.add_vertex(vert)
		surface.add_vertex(Vector3(vert.x + unit, vert.y, vert.z))
		surface.add_vertex(vert + Vector3(unit, 0, unit))
	
	var mesh := ArrayMesh.new()
	surface.commit(mesh)
	
	walkable_mesh.mesh = mesh
	nav_region.bake_navigation_mesh()
