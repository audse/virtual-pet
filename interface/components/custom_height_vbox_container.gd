@tool
class_name CustomHeightVBoxContainer
extends Container

enum HeightType {
	CONTAINER,
	PER_ROW,
}

@export var height_type: HeightType = HeightType.PER_ROW:
	set(value):
		height_type = value
		_sort_children()

@export var height: float:
	set(value):
		height = value
		_sort_children()

@export var resort: bool:
	set(_value): _sort_children()

var separation: int:
	get: return get_theme_constant("separation", "")

var row_height: float:
	get: 
		var num_children: int = get_child_count()
		match height_type:
			HeightType.CONTAINER:
				return (float(height) / float(num_children)) - (separation * (num_children - 1))
			HeightType.PER_ROW, _:
				return height


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN: _sort_children()


func _sort_children() -> void:
	var i: int = 0
	for child in get_children():
		var rect := Rect2(Vector2(child.position.x, (row_height + separation) * i), Vector2(child.size.x, row_height))
		if child.size_flags_horizontal == Control.SIZE_SHRINK_BEGIN: rect.position.x = 0
		fit_child_in_rect(child, rect)
		i += 1
	
	match height_type:
		HeightType.CONTAINER: size.y = height
		HeightType.PER_ROW: size.y = (height + separation) * get_child_count()
