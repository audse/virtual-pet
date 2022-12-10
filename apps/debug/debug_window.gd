extends Window

@onready var tree := %Tree as Tree
@onready var tree_world_data := tree.create_item()
@onready var tree_world_data_objects: TreeItem = tree_world_data.create_item()


func update_tree_world_data() -> void:
	tree_world_data
	pass
