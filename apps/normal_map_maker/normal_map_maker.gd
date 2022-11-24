extends Control

const NORMAL_MAP_GALLERY_PATH := "user://normal_maps/"
const SHADER = preload("res://apps/normal_map_maker/assets/shaders/height_map_to_normal_map.gdshader")

@onready var canvas: ColorRect = %Canvas

@onready var power: float:
	get: return %PowerRange.value if not inverted else -%PowerRange.value

@onready var inverted: bool:
	get: return not %InvertCheckbox.button_pressed

@onready var depth: float:
	get: return %DepthRange.value


func _ready() -> void:	
	Utils.adjust_margins_for_landscape($MarginContainer)
	
	if not DirAccess.dir_exists_absolute(NORMAL_MAP_GALLERY_PATH):
		DirAccess.make_dir_absolute(NORMAL_MAP_GALLERY_PATH)


#func load_image(path: String) -> void:
#	var image := Image.load_from_file(NORMAL_MAP_GALLERY_PATH + path + ".png")
#	var texture := ImageTexture.new().create_from_image(image)
#	canvas.set_meta("canvas_name", path)
#	canvas.material.set_shader_parameter("image", texture)


func _on_save_pressed(save_name: String) -> void:
	var path := NORMAL_MAP_GALLERY_PATH + save_name + ".png"
	%CanvasViewport.get_texture().get_image().save_png(path)


func _on_gallery_button_pressed() -> void:
	%Gallery.open()


func _on_gallery_canvas_selected(canvas_viewport: SubViewport, canvas_name: String) -> void:
	var image := canvas_viewport.get_texture()
	canvas.material.set_shader_parameter("image", image)
	canvas.material.set_shader_parameter("resolution", image.get_size())
	canvas.material.set_shader_parameter("power", -10)
	canvas.set_meta("canvas_name", canvas_name)
	%Gallery.close()
	%SaveButton.update_name_field(canvas_name)


func _on_invert_checkbox_toggled(_button_pressed: bool) -> void:
	canvas.material.set_shader_parameter("power", power)


func _on_save_button_pressed() -> void:
	%SaveButton.update_texture(%CanvasViewport.get_texture())


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to(load("res://main_menu.tscn"))


func _on_depth_value_changed(_value: float) -> void:
	canvas.material.set_shader_parameter("depth", depth)


func _on_power_value_changed(_value: float) -> void:
	canvas.material.set_shader_parameter("power", power)
