class_name ActionItem
extends Object

var container: Control
var parent: ActionMenu
var args: ActionItemParams
var button: Button

var id: 
	get: return args.id

func _init(container_value: Control, parent_value: ActionMenu, args_value: ActionItemParams) -> void:
	container = container_value
	parent = parent_value
	args = args_value


func make_button() -> Button:
	# Add submenu to tree
	if "submenu" in args and args.submenu and not args.submenu.is_inside_tree():
		container.add_child(args.submenu)
	
	if not button:
		# Make and add button to tree
		button = Button.new()
		button.text = args.text
		parent.add_child(button)
		button.pressed.connect(_on_pressed)
		
		# if args.is_cheat:
		# 	button.modulate = Color("#f0abfc")
		# 	button.text = "* " + button.text
	
	return button


func make_submenu() -> ActionMenu:
	if "submenu_params" in args and len(args.submenu_params) > 0:
		args.submenu = ActionMenu.new()
		args.submenu.overwrite_style = parent.overwrite_style
		container.add_child(args.submenu)
		args.submenu.append_actions(args.submenu_params)
		args.submenu.reset()
	return args.submenu


func _on_pressed() -> void:
	parent.action_pressed.emit(self)
	if "on_pressed" in args: args.on_pressed.call(self)
	if "submenu" in args and args.submenu:
		args.submenu.parent_action = self
		args.submenu.global_position = button.global_position + button.size / 2 - args.submenu.size / 2
		args.submenu._on_open()
	parent._on_close()
