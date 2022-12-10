extends CanvasLayer


var pet_data := PetData.new()
var color := PetColorData.new()

@onready var pet_preview := %PetPreview as SubViewport
@onready var open_file_dialog := %OpenFileDialog as FileDialog

@onready var id_field := %IdField as LineEdit
@onready var display_name_field := %DisplayNameField as LineEdit
@onready var save_location_field := %SaveLocationField as LineEdit
@onready var save_location_button := %SaveLocationButton as Button
@onready var save_button := %SaveButton as Button
@onready var open_button := %OpenButton as Button

@onready var albedo_color_button := %AlbedoColorButton as ColorPickerButton
@onready var albedo_texture_button := %AlbedoTextureButton as Button
@onready var albedo_texture_preview := %AlbedoTexturePreview as TextureRect
@onready var albedo_clear_texture_button := %ClearAlbedoTextureButton as Button

@onready var normal_texture_button := %NormalTextureButton as Button
@onready var normal_texture_preview := %NormalTexturePreview as TextureRect
@onready var normal_clear_texture_button := %ClearNormalTextureButton as Button
@onready var normal_scale_range := %NormalScaleRange as PillRange

@onready var bump_texture_button := %BumpTextureButton as Button
@onready var bump_texture_preview := %BumpTexturePreview as TextureRect
@onready var bump_clear_texture_button := %ClearBumpTextureButton as Button

@onready var ao_texture_button := %AOTextureButton as Button
@onready var ao_texture_preview := %AOTexturePreview as TextureRect
@onready var ao_clear_texture_button := %ClearAOTextureButton as Button

@onready var transparency_toggle := %TransparencyToggle as ToggleSwitch
@onready var diffused_lighting_toggle := %DiffusedLightingToggle as ToggleSwitch
@onready var roughness_range := %RoughnessRange as PillRange
@onready var metallic_range := %MetallicRange as PillRange

var bump_image: Image = null


func _enter_tree() -> void:
	pet_data.animal_data.color = color
	
	color.body_material = color.body_material.duplicate()
	color.detail_material = color.detail_material.duplicate()


func _ready() -> void:
	%HomeButton.pressed.connect(Modules.go_to_portal)
	
	var area := Utils.get_display_area(self)
	if area.size.x > 1366: %GridContainer.columns = 3
	
	open_file_dialog.size = area.size * Vector2(0.75, 0.5)
	open_file_dialog.position = area.size / 2 - Vector2(open_file_dialog.size) / 2
	
	pet_preview.pet_data = pet_data
	
	open_file_dialog.visibility_changed.connect(
		func(): Utils.disconnect_all(open_file_dialog.file_selected)
	)
	
	id_field.text_changed.connect(
		func(text: String) -> void:
			update_save_button()
			color.id = text
	)
	
	display_name_field.text_changed.connect(
		func(text: String) -> void: 
			update_save_button()
			color.display_name = text
	)
	
	save_location_field.text_changed.connect(func(_text): update_save_button())
	
	save_location_button.pressed.connect(
		func() -> void:
			open_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
			open_file_dialog.show()
	)
	
	open_file_dialog.dir_selected.connect(
		func(dir: String) -> void:
			save_location_field.text = dir.replace("res://mods/", "")
			open_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	)
	
	albedo_color_button.color = color.body_material.albedo_color
	albedo_color_button.color_changed.connect(update_albedo_color)
	
	update_normal_scale(normal_scale_range.value)
	normal_scale_range.value_changed.connect(update_normal_scale)
	
	transparency_toggle.toggled.connect(update_transparency)
	diffused_lighting_toggle.toggled.connect(update_diffused_lighting)
	
	for button in [albedo_texture_button, normal_texture_button, bump_texture_button, ao_texture_button, open_button]:
		button.pressed.connect(_on_upload_button_pressed.bind(button))
	
	for button in [albedo_clear_texture_button, normal_clear_texture_button, bump_clear_texture_button, ao_clear_texture_button]:
		var preview: TextureRect = button.get_parent()
		preview.mouse_entered.connect(func(): if preview.texture: button.visible = true)
		preview.mouse_exited.connect(func(): button.visible = false)
		button.visible = false
	
	albedo_clear_texture_button.pressed.connect(update_albedo_texture.bind(null))
	normal_clear_texture_button.pressed.connect(update_normal_texture.bind(null))
	bump_clear_texture_button.pressed.connect(update_bump_texture.bind(null))
	ao_clear_texture_button.pressed.connect(update_ao_texture.bind(null))
	
	roughness_range.value_changed.connect(update_roughness)
	metallic_range.value_changed.connect(update_metallic)
	
	update_save_button()
	save_button.pressed.connect(_on_save_pressed)


func update_save_button() -> void:
	pass
#	save_button.disabled = (
#		id_field.text.length() < 1 
#		or display_name_field.text.length() < 1
#		or save_location_field.text.length() < 1
#	)
#


func update_albedo_color(new_color: Color) -> void:
	color.body_material.albedo_color = new_color
	color.detail_material.albedo_color = ColorRef.multiply(new_color, Color.BLACK, 0.4)


func update_albedo_texture(texture: Texture2D) -> void:
	albedo_texture_preview.texture = texture
	color.body_material.albedo_texture = texture
	color.detail_material.albedo_texture = texture


func update_normal_texture(texture: Texture2D) -> void:
	color.body_material.normal_enabled = texture != null
	color.detail_material.normal_enabled = texture != null
	
	normal_texture_preview.texture = texture
	color.body_material.normal_texture = texture
	color.detail_material.normal_texture = texture
	
	bump_image = null


func update_bump_texture(texture: Texture2D) -> void:
	bump_texture_preview.texture = texture
	if texture:
		bump_image = texture.get_image().duplicate(true)
		if bump_image.is_compressed(): bump_image.decompress()
		bump_image.bump_map_to_normal_map(1.0)
		var image := ImageTexture.create_from_image(bump_image)
		
		color.body_material.normal_texture = image
		color.detail_material.normal_texture = image
		normal_texture_preview.texture = image
	else:
		color.body_material.normal_texture = normal_texture_preview.texture
		color.detail_material.normal_texture = normal_texture_preview.texture
	for mat in [color.body_material, color.detail_material]:
		mat.normal_enabled = mat.normal_texture != null


func update_normal_scale(val: float) -> void:
	color.body_material.normal_scale = val - 3 # correct for non-negative range values
	color.detail_material.normal_scale = val - 3


func update_ao_texture(texture: Texture2D) -> void:
	color.body_material.ao_enabled = texture != null
	color.detail_material.ao_enabled = texture != null
	
	ao_texture_preview.texture = texture
	color.body_material.ao_texture = texture
	color.detail_material.ao_texture = texture
	color.body_material.ao_light_affect = 0.25
	color.detail_material.ao_light_affect = 0.25


func update_transparency(enabled: bool) -> void:
	color.body_material.transparency = (
		BaseMaterial3D.TRANSPARENCY_ALPHA if enabled
		else BaseMaterial3D.TRANSPARENCY_DISABLED
	)
	color.detail_material.transparency = color.body_material.transparency


func update_diffused_lighting(enabled: bool) -> void:
	color.body_material.diffuse_mode = (
		BaseMaterial3D.DIFFUSE_LAMBERT if enabled
		else BaseMaterial3D.DIFFUSE_BURLEY
	)


func update_roughness(val: float) -> void:
	color.body_material.roughness = val
	color.detail_material.roughness = val


func update_metallic(val: float) -> void:
	color.body_material.metallic = val
	color.detail_material.metallic = val


func load_data(new_color: PetColorData, location: String) -> void:
	if not new_color: return
	
	pet_data.animal_data.color = new_color
	color = new_color
	
	id_field.text = color.id
	display_name_field.text = color.display_name
	save_location_field.text = location.replace("res://mods/", "").rsplit("/", true, 1)[0]
	
	albedo_color_button.color = color.body_material.albedo_color
	albedo_texture_preview.texture = color.body_material.albedo_texture
	normal_texture_preview.texture = color.body_material.normal_texture
	normal_scale_range.value = color.body_material.normal_scale + 3.0
	bump_texture_preview.texture = null
	ao_texture_preview.texture = color.body_material.ao_texture
	transparency_toggle.button_pressed = color.body_material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA
	diffused_lighting_toggle.button_pressed = color.body_material.diffuse_mode == BaseMaterial3D.DIFFUSE_LAMBERT
	roughness_range.value = color.body_material.roughness
	metallic_range.value = color.body_material.metallic
	
	update_save_button()


func _on_upload_button_pressed(button: Button) -> void:
	open_file_dialog.show()
	open_file_dialog.file_selected.connect(_on_file_selected.bind(button), CONNECT_ONE_SHOT)


func _on_file_selected(path: String, target: Button) -> void:
	var file = load(path)
	if not file and Utils.is_image_path(path): # not-yet-imported images need special loading
		var img := Image.load_from_file(path)
		if img: file = ImageTexture.create_from_image(img)
	if target == albedo_texture_button: update_albedo_texture(file as Texture2D)
	elif target == normal_texture_button: update_normal_texture(file as Texture2D)
	elif target == bump_texture_button: update_bump_texture(file as Texture2D)
	elif target == ao_texture_button: update_ao_texture(file as Texture2D)
	elif target == open_button: load_data(file as PetColorData, path)


func _on_save_pressed() -> void:
	if save_location_field.text.length() > 1 and id_field.text.length() > 1:
		var path := "res://mods/" + save_location_field.text
		if not DirAccess.dir_exists_absolute(path): DirAccess.make_dir_recursive_absolute(path)
		
		# Bump map is saved separately because it is auto-generated
		if color.body_material.normal_texture and bump_image:
			var bump_path: String = path + "/" + id_field.text + "_bump.png"
			bump_image.save_png(bump_path)
			bump_image.resource_path = bump_path
			var normal_texture := ImageTexture.create_from_image(bump_image)
			color.body_material.normal_texture = normal_texture
			color.detail_material.normal_texture = normal_texture
		
		ResourceSaver.save(color, path + "/" + id_field.text + ".petcolor.tres")
		
		save_button.modulate = ColorRef.EMERALD_300
		save_button.text = "Saved!"
		Ui.pop(save_button)
		await get_tree().create_timer(3.0).timeout
		save_button.text = "Save"
		save_button.modulate = Color.WHITE
