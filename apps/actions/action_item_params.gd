class_name ActionItemParams
extends Resource

var id
var text: String
var on_pressed: Callable
var submenu: ActionMenu
var submenu_params: Array[ActionItemParams]


func _init(args: Dictionary) -> void:
	match args:
		{ "id", .. }:
			id = args.id
			continue
		{ "text", .. }:
			text = args.text
			continue
		{ "on_pressed", .. }:
			on_pressed = args.on_pressed
			continue
		{ "submenu", .. }:
			submenu = args.submenu
			continue
		{ "submenu_params", .. }:
			submenu_params = args.submenu_params
			continue
