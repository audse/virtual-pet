class_name Pet
extends Node

@export var pet_data: PetData

@onready var camera: Camera3D = get_viewport().get_camera_3d()

@onready var behavior := %Behavior
@onready var actor := %Actor as PetActor
@onready var thoughts := %ThoughtBubble as ThoughtBubble
@onready var thoughts_label := %ThoughtBubbleLabel as Label
@onready var action_menu := %ActionMenu as Control


func _process(_delta: float) -> void:
	if is_inside_tree() and not Engine.is_editor_hint() and thoughts and camera:
		var actor_position: Vector2 = camera.unproject_position(actor.position)
		var ui_position: Vector2 = lerp(
			thoughts.position, 
			actor_position - (thoughts.size * thoughts.dots_pos),
			0.05
		)
		thoughts.position = ui_position


func _unhandled_input(event: InputEvent) -> void:
	if Ui.is_pressed(event) and Game.Mode.is_live:
		var event_position := Vector3Ref.project_position_to_floor(camera, event.position)
		if actor.rect.has_point(Vector2(event_position.x, event_position.z)):
			action_menu.open_at(event.position)
			get_viewport().set_input_as_handled()


func _ready() -> void:
	# Set up pet data
	action_menu.pet_data = pet_data
	behavior.pet_data = pet_data
	actor.pet_data = pet_data
	
	# Start AI ticking
	behavior.start()
	
	pet_data.command_data.start_command.connect(
		func(cmd: CommandData.Command, target: WorldObjectData) -> void:
			# pause action if the game is paused
			if Datetime.data.paused: await Datetime.data.time_unpaused
			
			# populate thought bubble
			if thoughts and cmd != CommandData.Command.IDLE:
				thoughts_label.text = {
					CommandData.Command.PLAY: "fun!!",
					CommandData.Command.LOUNGE: "blehh...",
					CommandData.Command.EAT: "food...",
					CommandData.Command.WASH: "stinkyy...",
					CommandData.Command.SLEEP: "sleeep...",
					CommandData.Command.PLAY_TOGETHER: "friend!!",
				}[cmd]
				await thoughts.open()
			
			# go to target object
			if target: await move_to_location(target.coord)
			
			if thoughts: thoughts.close()
			
			# wait for commands to finish (some commands take extra time)
			await get_tree().create_timer(2.0).timeout
			match cmd:
				CommandData.Command.EAT:
					actor.change_animation("Eat", true)
					await get_tree().create_timer(0.5).timeout
				CommandData.Command.SLEEP:
					await get_tree().create_timer(3.0).timeout
				CommandData.Command.LOUNGE:
					await get_tree().create_timer(1.0).timeout
				CommandData.Command.PLAY_TOGETHER:
					await get_tree().create_timer(2.0).timeout
			
			# pause action if the game is paused
			if Datetime.data.paused: await Datetime.data.time_unpaused
			
			# use object (updates needs and marks object as consumed)
			if target: UsePetData.new(pet_data).use_object(target, cmd)
			
			# fulfill wants
			var target_is_rare: bool = target.item_data.is_rare if target else false
			match pet_data.wants_data.wants:
				[WantsData.Want.PLAY_WITH_RARE_TOY, ..]:
					if cmd == CommandData.Command.PLAY and target_is_rare:
						pet_data.wants_data.fulfill_want(WantsData.Want.PLAY_WITH_RARE_TOY)
					continue
				[WantsData.Want.EAT_RARE_FOOD, ..]:
					if cmd == CommandData.Command.EAT and target_is_rare:
						pet_data.wants_data.fulfill_want(WantsData.Want.EAT_RARE_FOOD)
					continue
				[WantsData.Want.SLEEP_ON_RARE_BED, ..]:
					if cmd == CommandData.Command.SLEEP and target_is_rare:
						pet_data.wants_data.fulfill_want(WantsData.Want.SLEEP_ON_RARE_BED)
					continue
				[WantsData.Want.LOUNGE_ON_RARE_BED, ..]:
					if cmd == CommandData.Command.LOUNGE and target_is_rare:
						pet_data.wants_data.fulfill_want(WantsData.Want.LOUNGE_ON_RARE_BED)
					continue
				[WantsData.Want.PLAY_WITH_FRIEND, ..]:
					if cmd == CommandData.Command.PLAY_TOGETHER:
						pet_data.wants_data.fulfill_want(WantsData.Want.PLAY_WITH_FRIEND)
					continue
			
			pet_data.command_data.finish_command.emit(cmd)
	)


func move_to_location(location: Vector2) -> void:
	actor.go_to_location(Vector3(location.x, 0, location.y))
	await actor.navigator.navigation_finished


func place(location: Vector2) -> void:
	actor.position = Vector3(location.x, 0, location.y)
	actor._update_world_coord()
