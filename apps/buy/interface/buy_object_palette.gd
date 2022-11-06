extends TabContainer

@onready var category_nodes := {
	all_items = get_node("All items")
}

@onready var thumbnail_size: Vector2:
	get: 
		var base_size := Vector2(size.y - 150.0, size.y - 150.0)
		match Settings.data.thumbnail_size:
			5: return base_size
			4, 3: return base_size / 2.0
			1: return base_size / 4.0
			0: return base_size / 5.0
			_: return base_size / 3.0


func _ready() -> void:
	for category in BuyData.categories:
		_on_category_added(category)
	
	for object in BuyData.objects:
		_on_object_added(object)
	
	BuyData.category_added.connect(_on_category_added)
	BuyData.object_added.connect(_on_object_added)


func make_thumbnail(object: BuyableObjectData) -> BuyableObjectThumbnailViewport:
	var thumbnail := BuyableObjectThumbnailViewport.new(object)
	thumbnail.size_flags_horizontal = SIZE_EXPAND_FILL
	thumbnail.size_flags_vertical = SIZE_EXPAND_FILL
	thumbnail.custom_minimum_size = thumbnail_size * Vector2(object.dimensions.x, object.dimensions.y)
	return thumbnail


func _on_category_added(category: BuyCategoryData) -> void:
	var category_node := VFlowContainer.new()
	add_child(category_node)
	category_node.name = category.display_name
	category_nodes[category.id] = category_node


func _on_object_added(object: BuyableObjectData) -> void:
	# Add to category
	if len(object.category_id):
		var category_node: VFlowContainer = category_nodes[object.category_id]
		category_node.add_child(make_thumbnail(object))
	
	# Add to "All items"
	category_nodes.all_items.add_child(make_thumbnail(object))
