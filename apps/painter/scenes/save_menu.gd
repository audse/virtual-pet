extends Button

@onready var menu: DropMenu = %MenuControl
@onready var canvas: TextureRect = %CanvasTexture
@onready var area_button: Button = %AreaButton
@onready var save_button: Button = %SaveAsButton
@onready var success_button: Button = %SaveSuccessButton


func _ready() -> void:
	menu.opening.connect(func(): area_button.visible = true)
	menu.closing.connect(func(): area_button.visible = false)


func update_texture(canvas_texture: Texture2D) -> void:
	canvas.texture = canvas_texture


func _on_pressed() -> void:
	if not menu.is_open: menu.open()
	else: menu.close()


func _on_save_button_pressed() -> void:
	await Anim.pop_spin_exit(save_button)
	await Anim.pop_spin_enter(success_button)
	await get_tree().create_timer(1.0).timeout
	await Anim.pop_spin_exit(success_button)
	await Anim.pop_spin_enter(save_button)
	menu.close()


func _on_maybe_later_button_pressed() -> void:
	menu.close()


func _on_area_button_pressed() -> void:
	if menu.is_open: menu.close()
