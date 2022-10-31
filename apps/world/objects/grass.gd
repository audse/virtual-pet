extends ConsumableObject

@onready var area := %Area3D as Area3D

var height := 1.0

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)


func grow() -> void:
	height *= 1.25
	scale.y = height


func consume() -> void:
	height *= 0.5
	scale.y = height


func _on_body_entered(_body: Node3D) -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale:y", height * 0.5, 0.15)
	tween.tween_property(self, "scale:y", height * 1.1, 0.15)
	tween.tween_property(self, "scale:y", height * 0.8, 0.15)
	tween.tween_property(self, "scale:y", height * 1.05, 0.15)
	tween.tween_property(self, "scale:y", height * 1.0, 0.15)
