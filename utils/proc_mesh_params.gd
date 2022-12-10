class_name ProcMeshParams
extends Object

var mesh: ArrayMesh
var offset := Vector3.ZERO
var height: float = 0.0
var thickness: float = 0.0
var join: bool = true
var facing := Vector3.FORWARD

# Rounded rectangle
var corner_radius: float = 0.0
var corner_points: int = 1


func _init(args: Dictionary = {}) -> void:
	for arg in args.keys(): if arg in self: self[arg] = args[arg]
	if not mesh: mesh = ArrayMesh.new()
