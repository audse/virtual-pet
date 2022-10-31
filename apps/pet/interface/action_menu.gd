extends Control

@export var pet_data: PetData

@onready var action_menu := %ActionMenu as ActionMenu
@onready var needs_menu := ActionMenu.new()

var command_text := {
	CommandData.Command.PLAY: "go play!",
	CommandData.Command.LOUNGE: "go lay down!",
	CommandData.Command.EAT: "go eat!",
	CommandData.Command.WASH: "go wash up!",
	CommandData.Command.SLEEP: "go sleep!",
	CommandData.Command.IDLE: "stop that!",
}


enum {
	FULFILL_NEED = 100,
	CHANGE_NAME = 200,
	GIVE_OBJECT = 300,
	CUDDLE = 400,
	ABOUT = 500,
}


func _ready() -> void:
	add_child(needs_menu)
	
	needs_menu.append_actions(command_text.keys().map(
		func(command: CommandData.Command) -> ActionItemParams: return ActionItemParams.new({
			id = command,
			text = command_text[command],
			on_pressed = _on_action_pressed
		})
	))

	action_menu.append_actions([
		# Needs menu
		ActionItemParams.new({
			id = FULFILL_NEED,
			text = "do something...",
			submenu = needs_menu
		}),
		# Customize options
		ActionItemParams.new({
			id = CHANGE_NAME,
			text = "rename...",
			on_pressed = _on_rename_pressed,
		}),
		# Misc
		ActionItemParams.new({
			id = GIVE_OBJECT,
			text = "give something...",
			on_pressed = _on_give_object_pressed,
		}),
		ActionItemParams.new({
			id = CUDDLE,
			text = "cuddle...",
			on_pressed = _on_cuddle_pressed,
		}),
		ActionItemParams.new({
			id = ABOUT,
			text = "about...",
			on_pressed = _on_about_pressed,
		}),
	])


func _on_rename_pressed(_action: ActionItem) -> void:
	if pet_data: pet_data.interface_data.open_menu_pressed.emit(PetInterfaceData.Menu.RENAME)


func _on_give_object_pressed(_action: ActionItem) -> void:
	if pet_data: pet_data.interface_data.open_menu_pressed.emit(PetInterfaceData.Menu.GIVE_OBJECT)


func _on_cuddle_pressed(_action: ActionItem) -> void:
	if pet_data: pet_data.interface_data.open_menu_pressed.emit(PetInterfaceData.Menu.CUDDLE)


func _on_about_pressed(_action: ActionItem) -> void:
	if pet_data: pet_data.interface_data.open_menu_pressed.emit(PetInterfaceData.Menu.ABOUT)


func _on_action_pressed(action: ActionItem) -> void:
	if pet_data: pet_data.command_data.receive_command.emit(action.id)


func open_at(pos: Vector2) -> void:
	position = pos
	if not action_menu.open: action_menu._on_open()


func close() -> void:
	if action_menu.open: action_menu._on_close()
