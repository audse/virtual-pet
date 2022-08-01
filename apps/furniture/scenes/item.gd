extends StaticBody3D

enum Surface { GROUND, TABLE, WALL, CEILING }

@export var map_path: NodePath
@export var placement_rect_path: NodePath

@export var size := Vector3i(1, 1, 1)
@export var place_on: Surface = Surface.GROUND

@export var disabled: bool = false:
	set(value):
		disabled = value
		if is_inside_tree() and drag:
			drag.disabled = disabled

@onready var map: CellMap = get_node_or_null(map_path)
@onready var rect: PlacementRect = get_node_or_null(placement_rect_path)

var mesh: MeshInstance3D
var collider: CollisionShape3D
var drag: Draggable

var map_pos: Vector3:
	get: return map.world_to_map_to_world(position) if map else position

var world_size: Vector3:
	get: return Vector3(size) * map.grid.cell_size if map else size

var rect_size: Vector2:
	get:
		var deg: int = rad2deg(rotation.y)
		var rect_size = (
			Vector2(size.x, size.z) if deg == 0 or deg % 180 == 0
			else Vector2(size.z, size.x)
		)
		if map: rect_size *= Vector2(map.grid.cell_size.x, map.grid.cell_size.z)
		return rect_size

var rect_pos: Vector2:
	get:
		var m := map_pos
		return Vector2(m.x, m.z) - rect.rect.size / 2


func _ready() -> void:
	for child in get_children():
		if child is MeshInstance3D: mesh = child
		elif child is CollisionShape3D: collider = child
		elif child is Draggable: drag = child
	if drag:
		drag.disabled = disabled
		drag.drag_started.connect(_on_drag_started)
		drag.dragging.connect(_on_dragging)
		drag.drag_ended.connect(_on_drag_ended)
		drag.tapped.connect(_on_tapped)
	
	add_to_group("FurnitureItems")


func _on_drag_started() -> void:
	if rect:
		rect.rect.size = rect_size
		rect.thickness_to(0.02)
	for item in get_tree().get_nodes_in_group("FurnitureItems"):
		if not item == self: item.disabled = true


func _on_dragging() -> void:
	if rect: rect.queue_move_to(rect_pos)


func _on_drag_ended() -> void:
	for item in get_tree().get_nodes_in_group("FurnitureItems"):
		item.disabled = false
	var tween := _tween()
	tween.tween_property(self, "position", Vector3(map_pos.x, 0, map_pos.z), 0.25)
	if rect:
		rect.rect.size = rect_size
		await rect.thickness_to(0.0)


func _on_tapped() -> void:
	var tween := _tween()
	tween.tween_property(self, "rotation:y", rotation.y + deg2rad(90), 0.25)
	tween.tween_property(self, "position", Vector3(map_pos.x, 0, map_pos.z), 0.25)


func _tween(easing: int = Tween.EASE_IN_OUT) -> Tween:
	return create_tween().set_ease(easing).set_trans(Tween.TRANS_SINE).set_parallel()
