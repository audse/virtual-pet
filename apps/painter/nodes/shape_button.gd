@tool
extends Button

const Shape = States.PaintState.Shape

@export var shape: States.PaintState.Shape = Shape.SHARP
@export var reload: bool = false:
	get: return reload
	set(value):
		reload = false
		remake_texture()

var texture_rect: TextureRect


func _ready() -> void:
	pressed.connect(States.Paint.set_shape.bind(shape))
	States.Paint.shape_changed.connect(_on_shape_changed)


func _on_shape_changed(new_shape: int) -> void:
	disabled = new_shape != shape


func get_texture() -> Texture:
	var base_path := "res://apps/painter/assets/shapes/"
	match shape:
		Shape.SQUARE: base_path += "square.svg"
		Shape.SHARP: base_path += "sharp.svg"
		Shape.ROUND: base_path += "round.svg"
		Shape.CONCAVE: base_path += "concave.svg"
	return load(base_path)


func remake_texture() -> void:
	if texture_rect:
		remove_child(texture_rect)
	texture_rect = TextureRect.new()
	add_child(texture_rect)
	
	texture_rect.texture = get_texture()
	texture_rect.pivot_offset = Vector2(50, 50)
	texture_rect.size = Vector2(100, 100)
	texture_rect.set_anchors_preset(Control.PRESET_CENTER)
	size = Vector2(130, 130)
