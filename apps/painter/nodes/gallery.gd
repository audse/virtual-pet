extends Control


signal canvas_selected (canvas: SubViewport, path: String)

const GALLERY_PATH := "user://gallery"

var num_canvases: int:
	get: return %Viewports.get_child_count() - 1

# for overwrite warning/saving with same name warning
var current_canvases: Array[String] = []


func _ready() -> void:
	load_gallery()
	%PanelContainer.sort_children.connect(fit_panel)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED: fit_panel()


func fit_panel() -> void:
	var display_rect := Utils.get_display_area(self)
	var max_width = min(1200, display_rect.size.x - 48)
	
	if %PanelContainer.size.x < max_width:
		%PanelContainer.size_flags_horizontal = SIZE_EXPAND_FILL
	else:
		%PanelContainer.size_flags_horizontal = SIZE_SHRINK_END
		%PanelContainer.custom_minimum_size.x = max_width
	%Blur.size.x = %PanelContainer.size.x


func open() -> void:
	%GalleryDrawer.open()


func close() -> void:
	%GalleryDrawer.close()


func clear_gallery() -> void:
	for child in %CanvasGrid.get_children():
		if child != %CanvasTemplateSection: child.queue_free()
	
	for child in %Viewports.get_children():
		if child != %ViewportTemplate: child.queue_free()


func load_gallery() -> void:
	current_canvases = []
	clear_gallery()
	
	var finder := Directory.new()
	if not finder.dir_exists(GALLERY_PATH):
		finder.make_dir(GALLERY_PATH)
	
	finder.open(GALLERY_PATH)
	for canvas_path in finder.get_files():
		if ".canvas" in canvas_path:
			current_canvases.append(canvas_path)
			load_canvas(canvas_path)


func create_canvas_viewport() -> SubViewport:
	var viewport := %ViewportTemplate.duplicate()
	%Viewports.add_child(viewport)
	return viewport


func create_canvas_texture(canvas: SubViewport, canvas_name: String) -> VBoxContainer:
	var canvas_name_text := canvas_name.replace(".canvas", "")
	canvas.set_meta("canvas_name", canvas_name_text)
	var container: VBoxContainer = %CanvasTemplateSection.duplicate()
	%CanvasGrid.add_child(container)
	container.visible = true
	var button: TextureButton = container.get_child(0)
	button.texture_normal = canvas.get_texture()
	button.mouse_entered.connect(_on_canvas_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_canvas_mouse_exited.bind(button))
	button.pressed.connect(_on_canvas_pressed.bind(canvas))
	var label: Label = container.get_child(1)
	label.text = canvas_name_text
	
	var button_container = container.get_child(2)
	var download_button: Button = button_container.get_child(0)
	var success_button: Button = button_container.get_child(1)
	download_button.pressed.connect(download_image.bind(canvas, download_button, success_button))
	
	return container


func _on_canvas_pressed(canvas: SubViewport) -> void:
	canvas_selected.emit(canvas, canvas.get_meta("canvas_name"))
	close()


func load_canvas(path: String) -> int:	
	var file := File.new()	

	var viewport := create_canvas_viewport()
	
	var err = file.open(GALLERY_PATH + "/" + path, File.READ)
	if not err == OK or not viewport: return err
	
	viewport.set_meta("path", path)
	
	while file.get_position() < file.get_length():
		var pixel = file.get_var(true)
		if pixel is Sprite2D:
			viewport.add_child(pixel)
	
	create_canvas_texture(viewport, path)
	
	file.close()
	return OK


func download_image(canvas: SubViewport, button: Button, success_button) -> void:
	var path: String = canvas.get_meta("path").replace(".canvas", ".png")
	canvas.get_texture().get_image().save_png(GALLERY_PATH + "/" + path)
	await Anim.pop_spin_exit(button)
	await Anim.pop_spin_enter(success_button)
	await get_tree().create_timer(2.0).timeout
	await Anim.pop_spin_exit(success_button)
	await Anim.pop_spin_enter(button)


func _on_canvas_mouse_entered(canvas: TextureButton) -> void:
	canvas.pivot_offset = canvas.size / 2
	(get_tree()
		.create_tween()
		.tween_property(canvas, "scale", Vector2(1.1, 1.1), 0.1)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_CIRC))


func _on_canvas_mouse_exited(canvas: TextureButton) -> void:
	(get_tree()
		.create_tween()
		.tween_property(canvas, "scale", Vector2(1, 1), 0.1)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_CIRC))
