class_name ItemGrid
extends Node3D


@export var items: Array[ItemData] = []:
	set(value):
		items = value
		if is_inside_tree():
			update_previews()
			populate_grid()

@export var rows := 4
@export var margin := Vector2.ZERO
@export var show_price_label := false

## Array[Array[ItemData]] the items that belong to each space in the grid
var grid: Array[Array] = []
var previews: Array[ItemPreview]

@onready var rect := %Rect as MeshInstance3D


func _ready() -> void:
	use_test_items()


func use_test_items() -> void:
	# If viewing just this scene, populate the items with all the buyable items for testing purposes
	if get_tree().current_scene == self:
		items = BuyData.objects.filter(func(item: ItemData) -> bool: 
			return item.building_data == null and item.id != "little_pond"
		)


func update_previews() -> void:
	previews.map(remove_child)
	previews = items.map(
		func(item: ItemData) -> ItemPreview:
			return ItemPreview.new(item, show_price_label)
	)
	for preview in previews:
		add_child(preview)
		preview.mouse_entered.connect(_on_mouse_entered.bind(preview))


func populate_grid() -> void:
	grid.resize(1)
	for col in grid.size():
		grid[col] = []
		grid[col].resize(rows)
	
	var i := 0
	for item in items:
		var pos := find_empty_space(item)
		for coord in item.physical_data.used_coords:
			grid[pos.x + coord.x][pos.y + coord.y] = item
		previews[i].position = Vector3(pos.x, 0, pos.y) + Vector3(pos.x * margin.x, 0, pos.y * margin.y)
		i += 1


func find_empty_space(item: ItemData) -> Vector2i:
	var row_size := grid.size()
	for x in row_size:
		var col_size := grid[x].size()
		for y in col_size:
			var can_fit := true
			for item_coord in item.physical_data.used_coords:
				var coord := Vector2i(x + item_coord.x, y + item_coord.y)
				if row_size <= coord.x or col_size <= coord.y: can_fit = false
				elif grid[coord.x][coord.y] != null: can_fit = false
			if can_fit: return Vector2i(x, y)
	expand_grid(item.physical_data.dimensions.x)
	return find_empty_space(item)


func expand_grid(spaces: int) -> void:
	var added_rows := []
	added_rows.resize(spaces)
	for row in added_rows.size():
		added_rows[row] = []
		added_rows[row].resize(rows)
	grid.append_array(added_rows)


func _on_mouse_entered(preview: ItemPreview) -> void:
	var dimensions := preview.item.physical_data.dimensions
	rect.mesh.size = Vector2.ZERO
	var target_size := Vector2(dimensions.x, dimensions.z)
	rect.position = preview.position + Vector3(dimensions) * Vector3(0.5, 0, 0.5)
	Ui.tweener(rect).tween_property(rect, "mesh:size", target_size, 0.25)
