extends Node3D

@onready var pot := %PlantPot as MeshInstance3D


@onready var blend_shapes := {
	height = pot.find_blend_shape_by_name("Height"),
	rim = pot.find_blend_shape_by_name("Rim"),
	ring_1 = pot.find_blend_shape_by_name("Ring1"),
	ring_2 = pot.find_blend_shape_by_name("Ring2"),
	ring_3 = pot.find_blend_shape_by_name("Ring3"),
	bottom = pot.find_blend_shape_by_name("Bottom"),
}

func _ready():
	pass


func _on_rim_slider_value_changed(value: float) -> void:
	pot.set_blend_shape_value(blend_shapes.rim, value / 10)


func _on_ring_1_slider_value_changed(value: float) -> void:
	pot.set_blend_shape_value(blend_shapes.ring_1, value / 10)


func _on_ring_2_slider_value_changed(value: float) -> void:
	pot.set_blend_shape_value(blend_shapes.ring_2, value / 10)


func _on_ring_3_slider_value_changed(value: float) -> void:
	pot.set_blend_shape_value(blend_shapes.ring_3, value / 10)


func _on_bottom_slider_value_changed(value: float) -> void:
	pot.set_blend_shape_value(blend_shapes.bottom, value / 10)


func _on_height_slider_value_changed(value):
	pot.set_blend_shape_value(blend_shapes.height, value / 10)
