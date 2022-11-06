class_name ActionMenu
extends CircleMenuSimple

signal action_pressed(item: ActionItem)

@export var overwrite_style: bool = true

## The containing Control node- holds the submenus as siblings, rather than children
@export var container_path: NodePath = ".."
var container: Control

var parent_action: ActionItem

## Map of action item ids to action items
var actions: Dictionary = {}


func _ready() -> void:
	container = get_node(container_path)
	reset()
	super._ready()


func append_actions(actions_value: Array) -> void:
	for args in actions_value:
		actions[args.id] = ActionItem.new(container, self, args)
		if is_inside_tree(): 
			actions[args.id].make_button()
			actions[args.id].make_submenu()
	reset()


func append_action(args: ActionItemParams) -> void:
	actions[args.id] = ActionItem.new(container, self, args)
	if is_inside_tree(): 
		actions[args.id].make_button()
		actions[args.id].make_submenu()
		reset()


func reset() -> void:
	if is_inside_tree():
		mouse_filter = MOUSE_FILTER_IGNORE
		update_size()
		if open: _reset_opened()
		else: _reset_closed()
	
	if overwrite_style:
		background_color.a = 50.0 / 255.0
		tap_outside_to_close = true
		degree_offset = randf_range(-60.0, -10.0)
		animation_duration = 0.45


func update_size() -> void:
	var total_size: float = actions.values().reduce(
		func(total: float, item: ActionItem) -> float:
			return max(total, item.button.size.x) if item.button else total,
		0.0
	)
	if overwrite_style:
		custom_minimum_size = Vector2(total_size * 2.0, total_size * 2.0)
		set_anchors_and_offsets_preset(Control.PRESET_CENTER)
