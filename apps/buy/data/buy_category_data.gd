class_name BuyCategoryData
extends Resource

enum Menu {
	BUY,
	BUILD
}

@export var id: String
@export var display_name: String
@export var description: String = ""
@export var menu: Menu = Menu.BUY


func _init(args := {}) -> void:
	for key in args.keys():
		if key in self: self[key] = args[key]
