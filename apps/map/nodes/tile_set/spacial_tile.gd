class_name SpacialTile
extends MeshInstance3D
@icon("spacial_tile_icon.svg")

## Defines a unique ID string used to find this tile
@export var id: String

## Defines the bits (of 2D bitmask) that are "filled in" for this tile
@export_group("Bitmask")
@export var top_left: bool
@export var top_right: bool
@export var bottom_left: bool
@export var bottom_right: bool


func get_bitmask() -> BitMask:
	var bitmask := BitMask.new()
	bitmask.top_left = top_left
	bitmask.top_right = top_right
	bitmask.bottom_left = bottom_left
	bitmask.bottom_right = bottom_right
	return bitmask


func enter() -> void:
	scale.y = 0.0
	scale.x = 1.5
	scale.z = 1.5
	position.y = -0.2
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(self, "position:y", 0.0, 0.5)
	tween.tween_property(self, "scale:y", 1.0, 0.75)
	tween.tween_property(self, "scale:x", 1.0, 0.75)
	tween.tween_property(self, "scale:z", 1.0, 0.75)


func exit() -> void:
	await get_tree().create_timer(0.25).timeout
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale:x", 0.75, 0.2)
	tween.tween_property(self, "scale:z", 0.75, 0.2)
	tween.tween_property(self, "scale:y", 0.25, 0.5)
	tween.parallel().tween_property(self, "scale:x", 0.5, 0.5)
	tween.parallel().tween_property(self, "scale:z", 0.5, 0.5)
	tween.tween_callback(queue_free)
