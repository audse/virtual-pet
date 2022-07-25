extends Control

signal entered
signal exited
signal button_pressed(which: String)

enum Selecting { OUTER_WALL, INNER_WALL, FOUNDATION, FLOOR }

const NORMAL_MAP_GALLERY_PATH := "user://normal_maps/"

var selecting

func _ready() -> void:
	%Gallery.canvas_selected.connect(
		func(canvas: SubViewport, canvas_name: String) -> void:
			pass
	)


func _on_button_pressed(which: String) -> void:
	button_pressed.emit(which)


func _on_mouse_entered() -> void:
	entered.emit()


func _on_mouse_exited() -> void:
	exited.emit()


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to(load("res://main_menu.tscn"))


func _on_gallery_button_pressed() -> void:
	%Gallery.open()


func _on_gallery_canvas_selected(canvas: SubViewport, canvas_name: String) -> void:
	var image := canvas.get_texture()
	var normal := Image.load_from_file(NORMAL_MAP_GALLERY_PATH + canvas_name + ".png")
	if normal:
		var normal_texture := ImageTexture.new().create_from_image(normal)
		
		match selecting:
			Selecting.OUTER_WALL: States.Map.outer_wall_normal = normal_texture
			Selecting.INNER_WALL: States.Map.inner_wall_normal = normal_texture
			Selecting.FOUNDATION: States.Map.foundation_normal = normal_texture
			Selecting.FLOOR: States.Map.floor_normal = normal_texture
	
	match selecting:
		Selecting.OUTER_WALL: States.Map.outer_wall_tex = image
		Selecting.INNER_WALL: States.Map.inner_wall_tex = image
		Selecting.FOUNDATION: States.Map.foundation_tex = image
		Selecting.FLOOR: States.Map.floor_tex = image


func _on_outer_wall_gallery_button_pressed() -> void:
	selecting = Selecting.OUTER_WALL


func _on_inner_wall_gallery_button_pressed() -> void:
	selecting = Selecting.INNER_WALL


func _on_foundation_gallery_button_pressed() -> void:
	selecting = Selecting.FOUNDATION


func _on_floor_gallery_button_pressed() -> void:
	selecting = Selecting.FLOOR
