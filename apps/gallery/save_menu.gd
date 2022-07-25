extends Button

signal save_pressed(save_name: String)

@onready var menu: DropMenu = %MenuControl
@onready var canvas: TextureRect = %CanvasTexture
@onready var area_button: Button = %AreaButton
@onready var save_button: Button = %SaveAsButton
@onready var success_button: Button = %SaveSuccessButton
@onready var name_field: LineEdit = %CanvasNameField


func _ready() -> void:
	menu.opening.connect(toggle_area_button.bind(true))
	menu.closing.connect(toggle_area_button.bind(false))


func toggle_area_button(to_show: bool) -> void:
	if to_show:
		area_button.visible = true
		await Anim.fade_in(area_button)
	else: 
		await Anim.fade_out(area_button)
		area_button.visible = false


func update_texture(canvas_texture: Texture2D) -> void:
	canvas.set_deferred("texture", canvas_texture)


func update_name_field(canvas_name: String) -> void:
	name_field.text = canvas_name


func _on_pressed() -> void:
	if not menu.is_open: menu.open()
	else: menu.close()


func _on_save_button_pressed() -> void:
	save_button.text = "Saving..."
	save_button.disabled = true
	save_pressed.emit(name_field.text)
	await Anim.pop_spin_exit(save_button)
	await Anim.pop_spin_enter(success_button)
	await get_tree().create_timer(1.0).timeout
	await Anim.pop_spin_exit(success_button)
	await Anim.pop_spin_enter(save_button)
	save_button.text = "Save"
	save_button.disabled = false
	menu.close()


func _on_maybe_later_button_pressed() -> void:
	menu.close()


func _on_area_button_pressed() -> void:
	if menu.is_open: menu.close()
