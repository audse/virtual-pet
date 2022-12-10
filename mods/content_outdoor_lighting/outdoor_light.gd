extends WorldObjectMeshInstance

const SWITCH_ACTION_ID := "outdoor_light__switch"

var light := OmniLight3D.new()


func _ready() -> void:
	add_child(light)
	light.omni_attenuation = 2.0
	light.light_energy = 2.0
	
	update_all()
	super._ready()


func update_all() -> void:
	update_light()
	update_action_item()


func update_light() -> void:
	if context: 
		light.omni_range = 5.0 if context.object_data.is_on else 0.0
		light.position.y = get_y_pos()


func update_action_item() -> void:
	if not context: return
	
	if not context.action_menu.has_action(SWITCH_ACTION_ID):
		context.action_menu.action_menu.append_action(
			ActionItemParams.new({
				id = SWITCH_ACTION_ID,
				text = "turn on",
				on_pressed = _on_switched
			})
		)
	
	context.action_menu.action_menu.actions[SWITCH_ACTION_ID].button.text = get_button_text()


func get_button_text() -> String:
	if context and context.object_data and context.object_data.is_on: return "turn off"
	else: return "turn on"


func get_y_pos() -> float:
	if not context: return 0.0
	return {
		ground_circular_lightpost = 1.0
	}[context.object_data.item_data.id]


func _on_switched(_action_item: ActionItem) -> void:
	context.object_data.is_on = not context.object_data.is_on


func _on_context_changed() -> void:
	update_all()
	if context:
		context.object_data.is_on_changed.connect(
			func(_val): update_all()
		)
