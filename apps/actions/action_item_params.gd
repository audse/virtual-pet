class_name ActionItemParams
extends Resource

var id
var text: String
var on_pressed: Callable
var submenu: ActionMenu

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
