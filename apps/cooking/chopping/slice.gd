class_name ChopSlice
extends CSGMesh3D
@icon("slice.svg")

## the amount that this object will slide horizontally with each chop
@export var slide_amount: float = 0.1

## the amount that this object will slide vertically (bounce) with each chop
@export var bounce_amount: float = 0.1

## the amount that this object is hovering above ground (e.g. the amount it will fall when chopped)
@export var hover_amount: float = 0.0

## the amount that this object will rotate with each chop
@export var rotation_amount: int = 5

## the amount that this object will need to fall upon each rotation
@export var rotation_hover_offset_amount: float = 0.0

func chop() -> void:
	var tween := tweener()
	tween.tween_property(self, "position:z", position.z - slide_amount, 0.25)
	tween.tween_property(self, "rotation:x", rotation.x + deg2rad(rotation_amount), 0.25)
	tween.tween_property(self, "position:y", position.y - rotation_hover_offset_amount, 0.15)


func bounce() -> void:
	var tween := tweener()
	tween.tween_property(self, "position:y", position.y + bounce_amount, 0.15)
	tween.chain().tween_property(self, "position:y", position.y - hover_amount, 0.15)


func tweener() -> Tween:
	return (
		get_tree()
			.create_tween()
			.set_ease(Tween.EASE_IN_OUT)
			.set_trans(Tween.TRANS_SINE)
			.set_parallel(true)
	)
