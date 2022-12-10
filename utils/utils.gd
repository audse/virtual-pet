class_name Utils
extends Object


static func add_child_at(to: Node, child: Node, index: int) -> void:
	to.add_child(child)
	to.move_child(child, index)


static func transfer_child(from: Node, to: Node, child: Node, index: int = -1) -> void:
	from.remove_child(child)
	if index >= 0:
		add_child_at(to, child, index)
	else:
		to.add_child(child)


static func disconnect_all(sig: Signal) -> void:
	for callback in sig.get_connections(): sig.disconnect(callback.callable)


static func first_non_null(items: Array):
	for item in items:
		if item != null: return item
	return null


static func first_child_of_type(node: Node, type: String) -> Node:
	var children := node.get_children()
	if children.size() == 0: return null
	for child in children:
		if child.is_class(type): return child
	for child in children:
		var grandchild := Utils.first_child_of_type(child, type)
		if grandchild: return grandchild
	return null


static func get_display_area(node: Node) -> Rect2:
	if Engine.is_editor_hint():
		return Rect2(
			Vector2.ZERO, 
			Vector2(
				ProjectSettings.get_setting("display/window/size/viewport_width"),
				ProjectSettings.get_setting("display/window/size/viewport_height")
			)
		)
	else: return node.get_viewport().get_visible_rect()


static func is_landscape() -> bool:
	var area := Utils.get_display_area(Game)
	return area.size.x > area.size.y


static func adjust_margins_for_landscape(container: MarginContainer) -> void:
	var display_rect := Utils.get_display_area(container)
	if display_rect.size.x > display_rect.size.y:
		var margins := Vector2(display_rect.size.x * 0.05, 48)
		for margin in ["left", "right"]:
			container.add_theme_constant_override("margin_" + margin, margins.x as int)
		for margin in ["top", "bottom"]:
			container.add_theme_constant_override("margin_" + margin, margins.y as int + 72)


static func open_or_make_dir(path: String) -> DirAccess:
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_absolute(path)
	return DirAccess.open(path)


static func is_image_path(path: String) -> bool:
	return (
		".png" in path
		or ".jpg" in path
		or ".webp" in path
		or ".svg" in path
	)
