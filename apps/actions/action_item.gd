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
	return button


func _on_pressed() -> void:
	parent.action_pressed.emit(self)
	if "on_pressed" in args: args.on_pressed.call(self)
	if "submenu" in args and args.submenu:
		args.submenu.parent_action = self
		args.submenu.global_position = button.global_position + button.size / 2 - args.submenu.size / 2
		args.submenu._on_open()
	parent._on_close()
