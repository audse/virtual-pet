extends Control

const GALLERY_PATH := "user://gallery"


func _ready() -> void:
	load_gallery()


func open() -> void:
	%GalleryDrawer.open()


func close() -> void:
	%GalleryDrawer.close()


func load_gallery() -> void:
	var finder := Directory.new()
	if not finder.dir_exists(GALLERY_PATH):
		finder.make_dir(GALLERY_PATH)
	finder.open(GALLERY_PATH)
	for canvas_path in finder.get_files():
		load_canvas(canvas_path)


func create_canvas_viewport() -> SubViewport:
	var viewport := %ViewportTemplate.duplicate()
	%Viewports.add_child(viewport)
	return viewport


func create_canvas_texture(canvas: SubViewport) -> TextureRect:
	var rect: TextureRect = %CanvasTemplate.duplicate()
	%CanvasGrid.add_child(rect)
	rect.visible = true
	rect.texture.set_viewport_path_in_scene(get_path_to(canvas))
	rect.mouse_entered.connect(_on_canvas_mouse_entered.bind(rect))
	rect.mouse_exited.connect(_on_canvas_mouse_exited.bind(rect))
	return rect


func load_canvas(path: String) -> int:
	var file := File.new()
	
	var viewport := create_canvas_viewport()
	var canvas := viewport.get_node_or_null("Canvas")
	
	var err = file.open(GALLERY_PATH + "/" + path, File.READ)
	if not err == OK or not canvas: return err
	
	while file.get_position() < file.get_length():
		var pixel = file.get_var(true)
		if pixel is Sprite2D:
			canvas.add_child(pixel)
	
	create_canvas_texture(viewport)
	
	file.close()
	return OK


func _on_canvas_mouse_entered(canvas: TextureRect) -> void:
	canvas.pivot_offset = canvas.size / 2
	(get_tree()
		.create_tween()
		.tween_property(canvas, "scale", Vector2(1.1, 1.1), 0.15)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_CIRC))


func _on_canvas_mouse_exited(canvas: TextureRect) -> void:
	(get_tree()
		.create_tween()
		.tween_property(canvas, "scale", Vector2(1, 1), 0.15)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_CIRC))
