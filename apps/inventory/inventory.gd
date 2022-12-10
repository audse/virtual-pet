extends Node

var data: InventoryData = load_data()


func _ready() -> void:
	if data: data.save_data()


func load_data() -> InventoryData:
	for path in Utils.open_or_make_dir("user://game").get_files():
		if "inventory_data" in path: 
			var inventory_data = load("user://game/" + path)
			if inventory_data is InventoryData: return inventory_data.setup()
	return InventoryData.new()
