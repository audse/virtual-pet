@tool
class_name CircleContainer
extends Container
@icon("circle_container.svg")

enum Edge {
	LEFT,
	RIGHT,
	TOP,
	BOTTOM
}

@export var unsorted: Array[NodePath]:
	set(value):
		unsorted = value
		_sort_children()

@export var extra_margin := 0.0:
	set(value):
		extra_margin = value
		_temp_extra_margin = value

@export var fit_children_inside := false:
	set(value):
		fit_children_inside = value
		_sort_children()

@export var degree_range := 360.0:
	set(value):
		degree_range = value
		_temp_degree_range = value

@export var degree_offset := 0.0:
	set(value):
		degree_offset = value
		_temp_degree_offset = value

var unsorted_nodes: Array[Node]:
	get:
		var nodes = []
		for node_path in unsorted:
			var node: Node = get_node_or_null(node_path)
			if node: nodes.append(node)
		return nodes

var center: Vector2:
	get: return size / 2

var radius: float:
	get: 
		var shortest_side = min(size.x, size.y)
		return shortest_side / 2 - _temp_extra_margin

var num_children: int:
	get: return get_child_count() - len(unsorted_nodes) if is_inside_tree() else 0

var degree_increment: float:
	get: return _temp_degree_range / float(num_children if num_children > 0 else 1)


# Used for animation without losing original values
var _temp_extra_margin: float = extra_margin:
	set(value):
		_temp_extra_margin = value
		_sort_children()
		
var _temp_degree_range: float = degree_range:
	set(value):
		_temp_degree_range = value
		_sort_children()
		
var _temp_degree_offset: float = degree_offset:
	set(value):
		_temp_degree_offset = value
		_sort_children()

func _notification(what:int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN, NOTIFICATION_VISIBILITY_CHANGED, NOTIFICATION_RESIZED, NOTIFICATION_DRAW:
			_sort_children()


func get_controlled_children() -> Array[Control]:
	return (get_children()
		.filter(func(child: Node): return child is Control and not child in unsorted_nodes)
		.map(func(child: Node): return child as Control))


func _sort_children() -> void:
	var children: Array[Node] = get_controlled_children()
	
	var index: int = 0
	for child in children:
#		if child is Control and not child in unsorted_nodes:
		child.position = _find_pos_for(child, index)
		index += 1


func _find_pos_for(node: Control, index: int) -> Vector2:
	var degree: float = (degree_increment * index) + _temp_degree_offset
	
	if not fit_children_inside:
		return _to_circle_pos(center, radius, degree) - (node.size / 2)
	
	else:
		# create a new radius, customized to the current node's size
		var temp_center: Vector2 = center - (node.size / 2)
		var temp_radius: float = radius - (node.size.x / 2)
		return _to_circle_pos(temp_center, temp_radius, degree)


func _to_circle_pos(center_val: Vector2, radius_val: float, degree: float) -> Vector2:
	return Vector2(
		center_val.x + radius_val * cos(degree * (PI / 180)),
		center_val.y + radius_val * sin(degree * (PI / 180)),
	)
