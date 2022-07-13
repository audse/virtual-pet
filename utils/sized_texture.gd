@tool
class_name CustomSizeTexture2D
extends ImageTexture

@export var tex_path: String = "":
	set(value):
		tex_path = value
		image.load(tex_path)
		image.resize(size.x, size.y)
		update(image)

@export var size: Vector2i = Vector2(0, 0):
	set(value):
		size = value
		image.resize(size.x, size.y)
		update(image)

var image := Image.new()

func _init() -> void:
	image = Image.new()


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	set_size_override(size)
	super._draw(image.get_rid(), pos, modulate, transpose)


func draw(to_canvas_item: RID, pos: Vector2, modulate := Color.WHITE, transpose: bool = false) -> void:
	set_size_override(size)
	super.draw(image.get_rid(), pos, modulate, transpose)


func _get_width() -> int:
	return size.x
	

func get_width() -> int:
	return size.x


func _get_height() -> int:
	return size.y


func get_height() -> int:
	return size.y


func update(_i: Image) -> void:
	set_size_override(size)
	super.update(image)


func _get_image() -> Image:
	return image


func get_image() -> Image:
	return image
