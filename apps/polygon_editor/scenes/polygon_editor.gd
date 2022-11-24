class_name PolygonEditor
extends Node3D

signal polygon_changed(PackedVector2Array)

const EdgeScene := preload("edge.tscn")
const PointScene := preload("point.tscn")
const AddPointScene := preload("add_point.tscn")

@export var polygon := PackedVector2Array([
	Vector2(0, 0),
	Vector2(0, 4),
	Vector2(4, 4),
	Vector2(4, 0),
])

@export var join: bool = true

var edges: Array[PackedVector2Array] = []
var center := Vector2(2, 2)

@onready var walls_mesh := %Walls as MeshInstance3D


func _ready():
	polygon_changed.connect(_on_polygon_changed)
	polygon_changed.emit(polygon)
	
	await RenderingServer.frame_post_draw
	polygon_changed.emit(polygon)


func update_walls() -> void:
	walls_mesh.mesh = ProcMesh.new_wall(polygon, ProcMeshParams.new({ height = 2.0, join = join }))


func update_point_nodes() -> void:
	var point_nodes = PolygonEditorPoint.get_all(self)
	
	var i := 0
	for point in polygon:
		var node
		if len(point_nodes) > 0: node = point_nodes.pop_back()
		else:
			node = PointScene.instantiate()
			add_child(node)
			node.position_changed.connect(_on_position_changed)
		
		node.position = Vector3(point.x, 0, point.y)
		node.set_meta("index", i)
		i += 1


func update_edge_nodes() -> void:
	var edge_nodes = PolygonEditorEdgeHandle.get_all(self)
	
	var i := 0
	for edge in edges:
		var edge_node
		# use already-created edge_nodes first
		if len(edge_nodes) > 0: 
			edge_node = edge_nodes.pop_back()
		# otherwise, create new edge_nodes
		else: 
			edge_node = EdgeScene.instantiate()
			add_child(edge_node)
			edge_node.position_changed.connect(_on_edge_node_position_changed)
		
		# align edge_node to edge
		var pos := (edge[0] + edge[1]) / 2.0
		edge_node.position = Vector3(pos.x, 0, pos.y)
		edge_node.set_meta("index", i)
		edge_node.set_meta("p1", pos - edge[0])
		edge_node.set_meta("p2", pos - edge[1])
		edge_node.drag.fallback_position = edge_node.position
		
		i += 1
	
	# delete unused edge_nodes
	for edge_node in edge_nodes: edge_node.queue_free()


func update_add_point_buttons() -> void:
	var buttons = PolygonEditorAddPointButton.get_all(self)
	
	var i := 0
	for edge in edges:
		var pos := edge[0]
		var size := edge[1] - edge[0]
		
		var num_points := int(abs(size.length()))
		
		for point in range(1, num_points, 1):
			var percent: float = float(point) / float(num_points)
			var point_pos: Vector2 = pos.lerp(pos + size, percent)
			
			var button: Area3D
			if len(buttons) > 0: button = buttons.pop_back()
			else:
				button = AddPointScene.instantiate()
				add_child(button)
				button.input_event.connect(_on_add_point_button_input.bind(button))
			
			button.position = Vector3(point_pos.x, 0, point_pos.y)
			button.set_meta("index", i)
		i += 1
	
	for button in buttons: button.queue_free()


func set_point(index: int, to_pos: Vector2, bulk: bool = false) -> bool:
	var snapped: Vector2 = to_pos.snapped(Vector2(WorldData.grid_size, WorldData.grid_size))
	if not polygon[index].is_equal_approx(snapped):
		polygon[index] = snapped
		if not bulk: polygon_changed.emit(polygon)
		return true
	return false


func _on_position_changed(pos: Vector3, node) -> void:
	set_point(node.get_meta("index"), Vector2(pos.x, pos.z))


func _on_add_point_button_input(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _idx: int, button: Area3D) -> void:
	if Ui.is_pressed(event):
		var index: int = button.get_meta("index")
		var point := Vector2(int(button.position.x), int(button.position.z))
		polygon.insert(index, point)
		polygon_changed.emit(polygon)
		await RenderingServer.frame_post_draw
		polygon_changed.emit(polygon)
		button.queue_free()


func _on_edge_node_position_changed(pos: Vector3, node) -> void:
	var i: int = node.get_meta("index")
	var p1 := polygon[i]
	var p2 := polygon[i - 1]
	var start := (p2 + p1) / 2.0
	var curr := Vector2(pos.x, pos.z)
	
	if abs(curr.distance_to(start)) > 0.5:
		var offset1: Vector2 = node.get_meta("p2")
		var offset2: Vector2 = node.get_meta("p1")
		var p1_changed := set_point(i, curr - offset1, true)
		var p2_changed := set_point(i - 1, curr - offset2, true)
		if p1_changed or p2_changed: polygon_changed.emit(polygon)
		var center := (polygon[i] + polygon[i - 1]) / 2.0
		(node.get_child(0) as Draggable3D).fallback_position = Vector3(center.x, 0, center.y)


func _on_polygon_changed(_polygon) -> void:
	center = Polygon.get_center(polygon)
	edges = Polygon.get_edges(polygon, join)
	
	update_walls()
	update_edge_nodes()
	update_add_point_buttons()
	update_point_nodes()
