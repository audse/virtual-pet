extends Node3D

@onready var bed := %PetBed as MeshInstance3D


@onready var blend_shapes := {
	wall_height = bed.find_blend_shape_by_name("WallHeight"),
	roundness = bed.find_blend_shape_by_name("Roundness"),
}


func _on_wall_height_slider_value_changed(value):
	bed.set_blend_shape_value(blend_shapes.wall_height, value / 10)


func _on_roundness_slider_value_changed(value: float) -> void:
	bed.set_blend_shape_value(blend_shapes.roundness, value / 10)
