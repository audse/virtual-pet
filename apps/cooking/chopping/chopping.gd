extends Node3D


@onready var item: Choppable = $Choppable
@onready var knife: MeshInstance3D = $Knife

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed():
		item.chop()
		knife_chop()


func knife_chop() -> void:
	var pos := knife.position
	var tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	tween.tween_property(knife, "position:y", 0.5, 0.25)
	tween.tween_property(knife, "position:x", 0.5, 0.25)
	tween.tween_property(knife, "rotation:z", deg2rad(-20), 0.15)
	tween.chain().tween_property(knife, "rotation:z", deg2rad(5.0), 0.15)
	tween.chain().tween_property(knife, "position:y", pos.y, 0.25)
	tween.tween_property(knife, "position:x", pos.x, 0.25)
	tween.tween_property(knife, "rotation:z", deg2rad(-10), 0.15)
