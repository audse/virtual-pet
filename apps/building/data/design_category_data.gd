class_name DesignCategoryData
extends Resource


@export var id: String
@export var display_name: String
@export var description: String = ""
@export var design_type: DesignData.DesignType


func _init(args := {}) -> void:
	for key in args.keys():
		if key in self: self[key] = args[key]
