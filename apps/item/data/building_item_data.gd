class_name BuildingItemData
extends Resource


enum BuildingIntersectionType {
	OPEN_DOORWAY,
	CLOSED_DOORWAY,
	WINDOW,
}

@export var intersection_type: BuildingIntersectionType
@export var intersection_rect: Rect2


func _init(args := {}) -> void:
	for key in args.keys(): if key in self: self[key] = args[key]
