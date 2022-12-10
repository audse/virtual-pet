class_name TerrainData
extends Resource

const PATH := "user://game/terrain_data.tres"

@export var shape := PackedVector2Array()


func _init(generate := true) -> void:
	if generate: generate_shape(30)


func setup() -> TerrainData:
	changed.connect(save_data)
	return self


func generate_shape(num_points: int, smoothness: float = 0.6) -> void:
	var radius := (WorldData.size.x / 2) if WorldData else 50.0
	var points := Polygon.merge([
		Polygon.new_circle(radius, num_points),
#		Polygon.new_circle(radius * 0.75, num_points, Vector2(radius, radius) * 0.75),
	])
	
	var p_dist := 0.0 if points.size() < 2 else points[0].distance_to(points[1])
	
	# Randomize shape
	var p := 0
	var size := points.size()
	while p < size:
		points[p] += Vector2Ref.vrandf_range(-p_dist, p_dist)
		p += 1
	
	# Smooth shape
	p = 0
	while p < size:
		points[p] = points[p].lerp(points[p - 1], smoothness)
		p += 1
	
	shape = points


func get_used_coords() -> Array[Vector3i]:
	var size := Vector2i(WorldData.size / 2)
	var coords: Array[Vector3i] = []
	var pos := Vector2i(size * -1)
	while pos.x <= size.x:
		while pos.y <= size.y:
			var coord := Vector3i(pos.x, 0, pos.y)
			if has_coord(coord): coords.append(coord)
			pos.y += 1
		pos.x += 1
		pos.y = -size.y
	return coords


func has_coord(coord: Vector3i) -> bool:
	var offset := WorldData.grid_size_vector / 2.0
	var c3 := WorldData.to_world(coord)
	return Geometry2D.is_point_in_polygon(Vector2(c3.x, c3.z) + Vector2(offset.x, offset.z), shape)


func save_data() -> void:
	ResourceSaver.save(self, PATH)


static func load_data() -> TerrainData:
	if FileAccess.file_exists(PATH):
		var data := ResourceLoader.load(PATH)
		if data and data is TerrainData: return data.setup()
	var data := TerrainData.new().setup()
	data.save_data()
	return data
