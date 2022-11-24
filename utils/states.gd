# States
extends Node


var Paint = PaintState.new()
var Map = MapState.new()

var currently_dragging = null


func _enter_tree() -> void:
	add_child(Paint)
	add_child(Map)
