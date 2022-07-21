extends Node

var Random = RandomNumberGenerator.new()

func _ready() -> void:
	Random.randomize()


static func add_child_at(to: Node, child: Node, index: int) -> void:
	to.add_child(child)
	to.move_child(child, index)


static func transfer_child(from: Node, to: Node, child: Node, index: int = -1) -> void:
	from.remove_child(child)
	if index >= 0:
		add_child_at(to, child, index)
	else:
		to.add_child(child)


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


static func adjust_margins_for_landscape(container: MarginContainer) -> void:
	var display_rect := Utils.get_display_area(container)
	if display_rect.size.x > display_rect.size.y:
		var margins := Vector2(display_rect.size.x * 0.05, 48)
		for margin in ["left", "right"]:
			container.add_theme_constant_override("margin_" + margin, margins.x as int)
		for margin in ["top", "bottom"]:
			container.add_theme_constant_override("margin_" + margin, margins.y as int)
