class_name ProcMeshParams
extends Object

var offset := Vector3.ZERO
var height: float = 0.0
var thickness: float = 0.0
var join: bool = true

func _init(args: Dictionary = {}) -> void:
	for arg in args.keys(): if arg in self: self[arg] = args[arg]
