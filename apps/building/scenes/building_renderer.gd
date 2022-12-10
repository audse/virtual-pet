class_name BuildingRenderer
extends Node3D


const TEXTURE_SCALE := {
	DesignData.DesignType.INTERIOR_WALL: Vector3(0.5, 0.25, 0.5),
	DesignData.DesignType.EXTERIOR_WALL: Vector3(0.5, 0.25, 0.5),
	DesignData.DesignType.FLOOR: Vector3(0.5, 0.5, 0.5),
}

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
@onready var collision_shape := %CollisionShape3D as CollisionShape3D
@onready var roof_mesh := %Roof as MeshInstance3D

@onready var designs := {
	DesignData.DesignType.INTERIOR_WALL: interior_mesh,
	DesignData.DesignType.EXTERIOR_WALL: exterior_mesh,
	DesignData.DesignType.FLOOR: floor_mesh
}

@onready var thread := Thread.new()


func _ready() -> void:
	if get_tree().current_scene == self:
		thread.start(draw_building.bind(building_data.shape))
		update_all_designs()
	else:
		$Environment.queue_free()
		$RendererMarker3D.queue_free()
	
	Settings.data.hide_roofs_changed.connect(
		func(hide: bool) -> void: roof_mesh.visible = not hide
	)


func _exit_tree() -> void:
	thread.wait_to_finish()


func update_from_data(data: BuildingData) -> void:
	building_data = data
	thread.start(draw_building.bind(building_data.shape))
	update_all_designs()
	building_data.design_changed.connect(update_design)
#	building_data.rerender.connect(
#		func() -> void: thread.start(draw_building.bind(building_data.shape))
#	)


func draw_building(shape: PackedVector2Array) -> void:	
	# Add a bit of distortion
	for point in shape.size():
		shape[point] += Vector2(
			randf_range(distortion_range_start.x, distortion_range_end.x), 
			randf_range(distortion_range_start.y, distortion_range_end.y)
		)
	
	# Get the other components' polygons
	var inner_polygon := Polygon.shrink(shape, wall_thickness)
	
	# Draw all the components
	floor_mesh.mesh = ProcMesh.new_polygon(inner_polygon)
	wall_tops_mesh.mesh = ProcMesh.new_outline_polygon(shape, ProcMeshParams.new({ 
		thickness = wall_thickness, 
		offset = Vector3(0.0, wall_height, 0.0) 
	}))
	
	var outer_polygon := Polygon.grow(shape, wall_thickness)
	roof_mesh.mesh = ProcMesh.new_polygon(outer_polygon, ProcMeshParams.new({
		offset = Vector3(0.0, wall_height + floor_thickness, 0.0),
	}))
	roof_mesh.mesh = ProcMesh.new_wall(outer_polygon, ProcMeshParams.new({
		mesh = roof_mesh.mesh,
		offset = Vector3(0.0, wall_height, 0.0),
		height = floor_thickness,
	}))
	
	draw_walls(shape)
	update_collisions()


func draw_walls(shape: PackedVector2Array) -> void:
	exterior_mesh.mesh = null
	interior_mesh.mesh = null
	if not building_data: return
	
	var cutouts: Array[Array] = []
	
	var i := 0
	for edge in Polygon.get_edges(Polygon.grow(shape, 0.0)):
		var objects: Array[WorldObjectData] = building_data.get_objects_on_edge(edge[0], edge[1])
		cutouts.append(objects.map(
			func(object: WorldObjectData) -> Rect2: 
				if object.item_data.building_data: return Rect2(
					Vector2(object.coord).distance_to(edge[0]) + object.item_data.building_data.intersection_rect.position.x,
					object.item_data.building_data.intersection_rect.position.y,
					object.item_data.building_data.intersection_rect.size.x,
					object.item_data.building_data.intersection_rect.size.y
				)
				else: return Rect2(0, 0, 0, 0)
		))
		var rects: Array[Rect2] = cutouts[i]
		exterior_mesh.mesh = ProcMesh.new_wall_with_rect_cutouts(edge[0], edge[1], rects, ProcMeshParams.new({
			mesh = exterior_mesh.mesh,
			height = wall_height,
			facing = Polygon3.get_facing(edge[0], edge[1])
		}))
		i += 1
	i = 0
	for edge in Polygon.get_edges(Polygon.shrink(shape, wall_thickness)):
		var rects: Array[Rect2] = cutouts[i]
		interior_mesh.mesh = ProcMesh.new_wall_with_rect_cutouts(edge[0], edge[1], rects, ProcMeshParams.new({
			mesh = interior_mesh.mesh,
			height = wall_height,
			facing = Polygon3.get_facing(edge[0], edge[1], true)
		}))
		i += 1


func update_all_designs() -> void:
	if not building_data: return
	for design_type in designs.keys():
		var design: DesignData = (
			building_data.designs[design_type]
			if design_type in building_data.designs
			else BuildingData.DefaultDesign[design_type]
		)
		update_design(design_type, design)


func update_design(design_type: DesignData.DesignType, design: DesignData, _prev = null) -> void:
	var node := designs[design_type] as MeshInstance3D
	if node:
		(node.material_override as StandardMaterial3D).albedo_texture = design.albedo_texture
		(node.material_override as StandardMaterial3D).normal_texture = design.normal_texture
		(node.material_override as StandardMaterial3D).uv1_scale = TEXTURE_SCALE[design_type] * design.texture_scale


func update_collisions() -> void:
	collision_shape.make_convex_from_siblings()
