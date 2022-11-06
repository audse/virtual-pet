extends Control

@export var object_data: WorldObjectData

@onready var action_menu := %ActionMenu as ActionMenu
@onready var select_pet_menu := %SelectPetMenu as ActionMenu

var need_action_text := {
	NeedsData.Need.ACTIVITY: "play...",
	NeedsData.Need.COMFORT: "lounge...",
	NeedsData.Need.HUNGER: "eat this...",
	NeedsData.Need.HYGIENE: "wash up...",
	NeedsData.Need.SLEEPY: "sleep...",
}


func _ready() -> void:
	Modules.accept_modules(self)
	
	select_pet_menu.append_actions(WorldData.pets.map(
		func(pet: PetData) -> ActionItemParams: return ActionItemParams.new({
			id = pet,
			text = pet.name,
			on_pressed = self._on_action_pressed,
		})
	))
	
	for need in NeedsData.need_list:
		if object_data and need in object_data.buyable_object_data.fulfills_needs:
			action_menu.append_action(ActionItemParams.new({
				id = need,
				text = need_action_text[need],
				on_pressed = _on_action_pressed,
				submenu = select_pet_menu
			}))
	
	if object_data and BuyableObjectData.Flag.OWNABLE in object_data.buyable_object_data.flags:
		action_menu.append_action(ActionItemParams.new({
			id = "own",
			text = "set owner...",
			on_pressed = _on_action_pressed,
			submenu = select_pet_menu
		}))


func _on_action_pressed(action: ActionItem) -> void:
	if action.id is Resource and action.parent.parent_action:
		if action.parent.parent_action.id is String and action.parent.parent_action.id == "own":
			object_data.owner = action.id as PetData
		else:
			var need: NeedsData.Need = action.parent.parent_action.id
			var command: CommandData.Command = CommandData.CommandToNeedMap[need]
			(action.id as PetData).command_data.receive_command.emit(command)


func open_at(pos: Vector2) -> void:
	position = pos
	if not action_menu.open: action_menu._on_open()


func close() -> void:
	if action_menu.open: action_menu._on_close()
