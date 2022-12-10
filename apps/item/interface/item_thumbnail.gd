class_name ItemThumbnail
extends Object

const ItemThumbnailScene := preload("res://apps/item/interface/item_thumbnail.tscn")

var object: ItemData

## Dictionary[Control, ItemThumbnailScene]
var instances := {}

var min_size := Vector2.ZERO
var show_price: bool = true
var on_pressed: Callable

var object_size: Vector2:
	get: return Vector2(object.physical_data.dimensions.x, object.physical_data.dimensions.y)


func _init(object_value: ItemData, args := {}) -> void:
	object = object_value
	for arg in args: if arg in self: self[arg] = args[arg]


func make_instance() -> Button:
	var instance := ItemThumbnailScene.instantiate()
	instance.object_data = object
	instance.custom_minimum_size = min_size * object_size
	if on_pressed: instance.pressed.connect(on_pressed)
	return instance


func render(parent: Control = null) -> ItemThumbnail:
	if not parent: return self
	if not parent in instances: instances[parent] = make_instance()
	if not instances[parent].is_inside_tree() and not instances[parent].get_parent(): parent.add_child(instances[parent])
	instances[parent].label.visible = show_price
	
	return self


func render_all() -> ItemThumbnail:
	instances.keys().map(render)
	return self


func destroy() -> ItemThumbnail:
	for parent in instances.keys():
		if instances[parent] and instances[parent].is_inside_tree(): parent.remove_child(instances[parent])
	return self


func kill_all() -> void:
	for instance in instances.values():
		if instance and instance.is_inside_tree(): instance.queue_free()
