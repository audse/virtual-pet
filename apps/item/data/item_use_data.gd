class_name ItemUseData
extends Resource

@export var fulfills_needs: Array[NeedsData.Need] = []
@export var total_uses: int = -1 # infinite


func _init(args := {}) -> void:
	for key in args.keys(): if key in self: self[key] = args[key]
