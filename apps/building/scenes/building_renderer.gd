class_name BuildingRenderer
extends Node3D

@export var building_data: BuildingData
@export var wall_height := 4.0
@export var wall_thickness := 0.1
@export var floor_thickness := 0.2
@export var foundation_thickness := 0.1
@export var distortion_range_start := Vector2(-0.15, 0.15)
@export var distortion_range_end := Vector2(-0.15, 0.15)

@onready var floor_mesh := %Floor as MeshInstance3D
@onready var exterior_mesh := %ExteriorWalls as MeshInstance3D
@onready var interior_mesh := %InteriorWalls as MeshInstance3D
@onready var wall_tops_mesh := %WallTops as MeshInstance3D

@onready var designs := {
	DesignData.DesignType.INTERIOR_WALL: interior_mesh,
	DesignData.DesignType.EXTERIOR_WALL: exterior_mesh,
	DesignData.DesignType.FLOOR: floor_mesh
}

const TEXTURE_SCALE := {
	DesignData.DesignType.INTERIOR_WALL: Vector3(0.5, 0.25, 0.5),
	DesignData.DesignType.EXTERIOR_WALL: Vector3(0.5, 0.25, 0.5),
	DesignData.DesignType.FLOOR: Vector3(0.5, 0.5, 0.5),
}


func _ready() -> void:
	if get_tree().current_scene == self:
		draw_building(building_data.shape)
		update_all_designs()
	else:
		$RendererMarker3D/Camera3D.current = false
		$Environment.queue_free()
		$RendererMarker3D.queue_free()


func update_from_data(data: BuildingData) -> void:
	building_data = data
	building_data.shape = building_data.get_shape_from_coords()
	draw_building(building_data.shape)
	update_all_designs()
	update_collisions()
	building_data.shape_changed.connect(tween_shape)
	building_data.design_changed.connect(update_design)


func tween_shape(prev_shape: PackedVector2Array, current_shape: PackedVector2Array) -> void:
	if prev_shape.size() != current_shape.size(): 
		draw_building(current_shape)
		return
	
	prev_shape = Polygon.sort(prev_shape)
	current_shape = Polygon.sort(current_shape)
	
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK).set_parallel()
	
	for i in prev_shape.size():
		if prev_shape[i] != current_shape[i]:
			tween.tween_method(
				func(pos: Vector2) -> void:
					prev_shape[i] = pos
					draw_building(prev_shape),
				prev_shape[i],
				current_shape[i],
				0.5
			)
	
	await tween.finished
	update_collisions()


func draw_building(shape: PackedVector2Array) -> void:
	# Get building's polygon
	var polygon := Polygon.shrink(shape, 0.0)
	
	# Add a bit of distortion
	for point in polygon.size():
		polygon[point] += Vector2(
			randf_range(distortion_range_start.x, distortion_range_end.x), 
			randf_range(distortion_range_start.y, distortion_range_end.y)
		)
	
	# Get the other components' polygons
	var inner_polygon := Polygon.shrink(polygon, wall_thickness)
	var outer_polygon := Polygon.grow(polygon, foundation_thickness)
	
	# Draw all the components
	floor_mesh.mesh = ProcMesh.new_polygon(inner_polygon)
	exterior_mesh.mesh = ProcMesh.new_wall(polygon, ProcMeshParams.new({ height = wall_height }))
	interior_mesh.mesh = ProcMesh.new_wall(inner_polygon, ProcMeshParams.new({ height = wall_height }))
	wall_tops_mesh.mesh = ProcMesh.new_outline_polygon(polygon, ProcMeshParams.new({ 
		thickness = wall_thickness, 
		offset = Vector3(0.0, wall_height, 0.0) 
	}))


func update_all_designs() -> void:
	if not building_data: return
	for design_type in designs.keys():
		var design: DesignData = (
			building_data.designs[design_type]
			if design_type in building_data.designs
			else BuildingData.DefaultDesign[design_type]
		)
		update_design(design_type, design)


func update_design(design_type: DesignData.DesignType, design: DesignData) -> void:
	var node := designs[design_type] as MeshInstance3D
	if node:
		(node.material_override as StandardMaterial3D).albedo_texture = design.albedo_texture
		(node.material_override as StandardMaterial3D).normal_texture = design.normal_texture
		(node.material_override as StandardMaterial3D).uv1_scale = TEXTURE_SCALE[design_type] * design.texture_scale


func update_collisions() -> void:
	for mesh in [floor_mesh, exterior_mesh, interior_mesh, wall_tops_mesh]:
		for child in (mesh as Node).get_children():
			child.queue_free()
		(mesh as MeshInstance3D).create_convex_collision()
