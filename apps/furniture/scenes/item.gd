extends StaticBody3D

@export var map_path: NodePath
@export var placement_rect_path: NodePath

@export var object_data: WorldObjectData

@export var disabled: bool = false:
	set(value):
		disabled = value
		if drag: drag.disabled = disabled

@onready var map: CellMap = get_node_or_null(map_path)
@onready var rect: PlacementRect = get_node_or_null(placement_rect_path)

var mesh: MeshInstance3D
var collider: CollisionShape3D
var drag: Draggable

var map_pos: Vector3:
	get: return map.world_to_map_to_world(position) if map else position

var rect_pos: Vector2:
	get: return Vector2(map_pos.x, map_pos.z) - rect.rect.size / 2.0

var _start_pos: Vector3


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
	_start_pos = map_pos
	if rect:
		rect.rect.size = object_data.get_rect().size
		rect.thickness_to(0.02)
	for item in get_tree().get_nodes_in_group("FurnitureItems"):
		if not item == self: item.disabled = true


func _on_dragging() -> void:
	if rect: rect.queue_move_to(rect_pos)


func _on_drag_ended() -> void:
	for item in get_tree().get_nodes_in_group("FurnitureItems"):
		item.disabled = false
	var tween := _tween()
	tween.tween_property(self, "position", map_pos, 0.25)
	if rect:
		await rect.thickness_to(0.0)


func _on_tapped() -> void:
	if abs(_start_pos.distance_to(map_pos)) < 0.25:
		var tween := _tween()
		tween.tween_property(self, "rotation:y", rotation.y + deg_to_rad(90), 0.15)
		tween.tween_property(self, "rect:rect:size", Vector2(rect.rect.size.y, rect.rect.size.x), 0.15)
		tween.chain().tween_property(self, "position", map_pos, 0.15)


func _tween(easing: int = Tween.EASE_IN_OUT) -> Tween:
	return create_tween().set_ease(easing).set_trans(Tween.TRANS_SINE).set_parallel()
