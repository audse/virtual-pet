class_name ChopSlice
extends RigidDynamicBody3D
@icon("slice.svg")

const COLLISION_OVERLAP := 0.005
enum AutoCollisionShape {
	NONE,
	CYLINDER
}

## if `true`, the `linear_damp` property will automatically be calculated
## from the inverse of the mass (so lighter objects will have more dampening)
@export var calculate_damp_from_mass := true
@export var damp_range := Vector2(1, 6)

## creates a cylinder collision shape sibling (assumes the mesh is vertical, with slices stacked)
## NEEDS WORK ...
@export var auto_collision_shape: AutoCollisionShape = AutoCollisionShape.CYLINDER

@onready var mesh := get_child(0) as MeshInstance3D


func _ready() -> void:
	match auto_collision_shape:
		AutoCollisionShape.CYLINDER:
			var bounds := mesh.get_transformed_aabb()
			var shape := CollisionShape3D.new()
			shape.shape = CylinderShape3D.new()
			shape.position = bounds.position
			shape.shape.height = bounds.size.y - COLLISION_OVERLAP
			shape.shape.radius = bounds.size.x / 2 - COLLISION_OVERLAP
			add_child(shape)
	
	freeze = true
	collision_layer = -1
	collision_mask = -1
	
	if calculate_damp_from_mass:
		linear_damp = lerp(damp_range.x, damp_range.y, 1.0 - mass)


func chop(chop_force: Vector3, target_collision_layer := 1) -> void:
	freeze = false
	collision_layer = target_collision_layer
	collision_mask = target_collision_layer
	apply_central_impulse(chop_force)
