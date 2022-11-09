extends Control

signal opening
signal opened
signal closing
signal closed

@onready var button := %Button as Button
@onready var tabs := %TabContainer as TabContainer

@onready var category_nodes := {
	all_items = {
		scroll_container = tabs.get_node("All items"),
		flow_container = tabs.get_node("All items/VFlowContainer")
	}
}

@onready var thumbnail_size: Vector2:
	get: 
		var current_size = tabs.get_parent_area_size() * 0.65
		var base_size := Vector2(current_size.y, current_size.y)
		match Settings.data.thumbnail_size:
			5: return base_size
			4, 3: return base_size / 2.0
			1: return base_size / 4.0
			0: return base_size / 5.0
			_: return base_size / 3.0

var is_open: bool = false


func _ready() -> void:
	anchor_top = 0.6
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	button.pivot_offset = button.size / 2.0
	button.pressed.connect(
		func() -> void:
			if is_open: close()
			else: open()
	)
	
	if get_tree().current_scene == self:
		create()
		open()
	
	Game.Mode.enter_state.connect(
		func(state: GameModeState.Mode) -> void:
			if state == GameModeState.Mode.BUY:
				visible = true
				create()
				open()
			else:
				await close()
				destroy()
				visible = false
	)
	# Close menu to focus on placement when buying an object
	BuyData.object_bought.connect(func(_obj): close())


func create() -> void:
	# Create category tabs
	for category in BuyData.categories: add_category(category)
	# Add items
	for object in BuyData.objects: add_object(object)


func destroy() -> void:
	for category_node in tabs.get_children():
		if category_node.name != "All items":
			category_node.queue_free()
	for object_node in category_nodes.all_items.flow_container.get_children():
		object_node.queue_free()


func open() -> void:
	opening.emit()
	tabs.current_tab = 0
	visible = true
	
	# Expand container
	anchor_left = 0.925
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT).set_parallel()
	tween.tween_property(self, "anchor_left", 0.2, Settings.anim_duration(0.45))
	tween.tween_property(button, "rotation", deg_to_rad(0.0), Settings.anim_duration(0.5))
	tween.tween_property(tabs, "modulate:a", 1.0, Settings.anim_duration(0.35))
	await tween.finished
	
	is_open = true
	opened.emit()


func close() -> void:
	closing.emit()
	
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT).set_parallel()
	tween.tween_property(self, "anchor_left", 0.925, Settings.anim_duration(0.35))
	tween.tween_property(button, "rotation", deg_to_rad(180.0), Settings.anim_duration(0.45))
	tween.tween_property(tabs, "modulate:a", 0.0, Settings.anim_duration(0.35))
	await tween.finished
	
	is_open = false
	closed.emit()


func make_thumbnail(object: BuyableObjectData) -> BuyableObjectThumbnail:
	var thumbnail := BuyableObjectThumbnail.new(object)
	thumbnail.custom_minimum_size = thumbnail_size * Vector2(object.dimensions.x, object.dimensions.y)
	return thumbnail


func add_category(category: BuyCategoryData) -> void:
	var scroll_container := ScrollContainer.new()
	var flow_container := VFlowContainer.new()
	
	tabs.add_child(scroll_container)
	scroll_container.add_child(flow_container)
	
	scroll_container.name = category.display_name
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	flow_container.size_flags_horizontal = SIZE_EXPAND_FILL
	flow_container.size_flags_vertical = SIZE_EXPAND_FILL
	
	category_nodes[category.id] = {
		scroll_container = scroll_container,
		flow_container = flow_container
	}


func add_object(object: BuyableObjectData) -> void:
	# Add to category
	if len(object.category_id):
		var category_node = category_nodes[object.category_id]
		category_node.flow_container.add_child(make_thumbnail(object))
	
	# Add to "All items"
	category_nodes.all_items.flow_container.add_child(make_thumbnail(object))
