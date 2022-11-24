extends Control

signal opening
signal opened
signal closing
signal closed

@export var menu: BuyCategoryData.Menu = BuyCategoryData.Menu.BUY

@onready var button := %Button as Button
@onready var tabs := %TabContainer as TabContainer

@onready var category_nodes := {
	all_items = {
		scroll_container = tabs.get_node("All items"),
		flow_container = tabs.get_node("All items/VFlowContainer")
	}
}

@onready var object_nodes := {}

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
			if state == GameModeState.Mode.BUY and menu == BuyCategoryData.Menu.BUY:
				visible = true
				create()
				open()
			elif state == GameModeState.Mode.BUILD and menu == BuyCategoryData.Menu.BUILD:
				create()	
	)
	
	Game.Mode.exit_state.connect(
		func(state: GameModeState.Mode) -> void:
			if (
				(state == GameModeState.Mode.BUY and menu == BuyCategoryData.Menu.BUY)
				or (state == GameModeState.Mode.BUILD and menu == BuyCategoryData.Menu.BUILD)
			):
				await close()
				destroy()
				visible = false
	)
	
	# Close menu to focus on placement when buying an object
	BuyData.object_bought.connect(func(_obj): close())


func create() -> void:
	# Create category tabs
	for category in BuyData.categories: 
		if category.menu == menu: add_category(category)
	# Add items
	for object in BuyData.objects:
		if len(object.category_id) and object.category_id in category_nodes:
			add_object(object)


func destroy() -> void:
	for category_node in category_nodes.values():
		tabs.remove_child(category_node.scroll_container)


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


func add_category(category: BuyCategoryData) -> void:
	if not category.id in category_nodes:
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
	else:
		tabs.add_child(category_nodes[category.id].scroll_container)


func add_object(object: BuyableObjectData) -> void:
	if not object.id in object_nodes: object_nodes[object.id] = (
		BuyableObjectThumbnailNode
			.new(object, thumbnail_size)
			.render(category_nodes.get(object.category_id, {}), category_nodes.all_items)
	)
	else: object_nodes[object.id].render()


class BuyableObjectThumbnailNode:
	
	const BuyableObjectThumbnailScene := preload("res://apps/buy/scenes/buyable_object_thumbnail.tscn")

	var object: BuyableObjectData
	
	var category_tab: Button
	var all_tab: Button
	
	var category_container: Dictionary
	var all_items_container: Dictionary
	
	var object_size: Vector2:
		get: return Vector2(object.dimensions.x, object.dimensions.y)
	
	
	func _init(object_value: BuyableObjectData, min_size: Vector2) -> void:
		object = object_value
		
		category_tab = BuyableObjectThumbnailScene.instantiate()
		category_tab.object_data = object
		
		all_tab = BuyableObjectThumbnailScene.instantiate()
		all_tab.object_data = object
		
		category_tab.custom_minimum_size = min_size * object_size
		all_tab.custom_minimum_size = min_size * object_size
	
	
	func render(
		category_container_value := category_container,
		all_items_container_value := all_items_container
	) -> BuyableObjectThumbnailNode:
		category_container = category_container_value
		all_items_container = all_items_container_value
		
		if category_container.size(): category_container.flow_container.add_child(category_tab)
		all_items_container.flow_container.add_child(all_tab)
		
		return self
	
	
	func destroy() -> BuyableObjectThumbnailNode:
		if category_tab.is_inside_tree() and category_container.size(): category_container.flow_container.remove_child(category_tab)
		if all_tab.is_inside_tree(): all_items_container.flow_container.remove_child(all_tab)
		
		return self
