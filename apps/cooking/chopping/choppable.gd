class_name Choppable
extends Node3D
@icon("choppable.svg")

@onready var slices: Array = get_children()

## the amount that each object will be pushed when chopped
@export var chop_force := Vector3(-0.5, 0.25, 0)

## overrides all `ChopSlice` children with a given `PhysicsMaterial`
@export var physics_material_override: PhysicsMaterial

## the collision layer that will be activated when a slice is chopped
@export_flags_2d_physics var target_collision := 1

## AABB bounds will be grown by the given amount. useful to add more space for input
@export var grow_bounds: float = 0

@onready var bounds: AABB

var _current := 0


func _ready() -> void:
	slices = slices.filter(
		func (child: Node) -> bool: return child is ChopSlice
	)
	
	if physics_material_override: 
		for slice in slices:
			slice.physics_material_override = physics_material_override
	
	_update_bounds()


func _update_bounds() -> void:
	bounds = AABB(Vector3.ZERO, Vector3.ZERO)
	for i in range(len(slices) - 1, _current, -1):
		var slice: ChopSlice = slices[i]
		bounds = bounds.merge(slice.mesh.get_transformed_aabb())
	bounds = bounds.grow(grow_bounds)


func chop() -> void:
	
	if _current < len(slices):
		var slice: ChopSlice = slices[_current]
		if slice: slice.chop(chop_force, target_collision)
		
		_current += 1
	
	if _current == len(slices) - 1:
		var slice: ChopSlice = slices[_current]
		if slice: slice.chop(Vector3.ZERO, target_collision)
		_current += 1
	
	_update_bounds()
