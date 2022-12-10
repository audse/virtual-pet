class_name CanvasData
extends Resource

const GALLERY_PATH := "user://gallery"

@export var name: String = "Canvas"
@export var pixels: Array[Sprite2D] = []

var full_path: String:
	get: return GALLERY_PATH + "/" + name + ".tres"


func render(parent: Node) -> void:
	for pixel in pixels: parent.add_child(pixel)


func save_data() -> void:
	ResourceSaver.save(self, GALLERY_PATH + "/" + name + ".tres")


static func create(canvas_name: String, canvas: Canvas) -> CanvasData:
	var data := CanvasData.new()
	data.name = canvas_name
	for pixel in canvas.canvas.get_children():
		if pixel is Sprite2D and pixel not in [canvas.cursor, canvas.ghost]: data.pixels.append(pixel)
	return data


static func load_data(path: String) -> CanvasData:
	if ".tres" in path or ".res" in path:
		var data := ResourceLoader.load(path)
		if data is CanvasData: return data
	return null


static func load_all_data() -> Array[CanvasData]:
	var data: Array[CanvasData] = []
	for path in Utils.open_or_make_dir(GALLERY_PATH).get_files():
		var canvas := CanvasData.load_data(GALLERY_PATH + "/" + path)
		if canvas: data.append(canvas)
	return data
