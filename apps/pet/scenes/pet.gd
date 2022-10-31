class_name Pet
extends Node

@export var pet_data: PetData

@onready var camera: Camera3D = get_viewport().get_camera_3d()

@onready var behavior := %Behavior
@onready var actor := %Actor as PetActor
@onready var thoughts := %ThoughtBubble as ThoughtBubble

func _process(_delta: float) -> void:
	if is_inside_tree() and not Engine.is_editor_hint() and thoughts and camera:
		var actor_position: Vector2 = camera.unproject_position(actor.position)
		var ui_position: Vector2 = lerp(
			thoughts.position, 
			actor_position - (thoughts.size * thoughts.dots_pos * 1.25),
			0.05
		)
		thoughts.position = ui_position


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var event_position := Vector3Ref.project_position_to_floor_simple(camera, event.position)
		if actor.rect.has_point(Vector2(event_position.x, event_position.z)):
			%ActionMenu.open_at(event.position)
			get_viewport().set_input_as_handled()


func _ready() -> void:
	# Set up pet data
	%ActionMenu.pet_data = pet_data
	behavior.pet_data = pet_data
	actor.pet_data = pet_data
	
	# Start AI ticking
	behavior.start()
	
	
	pet_data.command_data.start_command.connect(
		func(cmd: CommandData.Command, target: WorldObjectData) -> void:
			if thoughts: thoughts.open()
			
			match cmd:
				CommandData.Command.EAT:
					thoughts.open()
					%ThoughtBubbleLabel.text = "food..."
				CommandData.Command.SLEEP: 
					thoughts.open()
					%ThoughtBubbleLabel.text = "sleeep..."
				CommandData.Command.PLAY:
					thoughts.open()
					%ThoughtBubbleLabel.text = "fun!!"
				CommandData.Command.LOUNGE: 
					thoughts.open()
					%ThoughtBubbleLabel.text = "blehh..."
				CommandData.Command.WASH:
					thoughts.open()
					%ThoughtBubbleLabel.text = "stinkyy..."
			
			if target:
				await move_to_location(target.coord)
				await get_tree().create_timer(1.0).timeout
			
			if thoughts: thoughts.close()
			
			match cmd:
				CommandData.Command.EAT:
					%ThoughtBubbleLabel.text = "food..."
					pet_data.needs_data.eat()
					target.consume()
						
				CommandData.Command.SLEEP: 
					%ThoughtBubbleLabel.text = "sleeep..."
					# sleeping takes a long time
					await get_tree().create_timer(3.0).timeout
					pet_data.needs_data.sleep()
				CommandData.Command.PLAY:
					%ThoughtBubbleLabel.text = "fun!!"
					pet_data.needs_data.play()
				CommandData.Command.LOUNGE: 
					%ThoughtBubbleLabel.text = "blehh..."
					# lounging takes more time
					await get_tree().create_timer(1.0).timeout
					pet_data.needs_data.lounge()
				CommandData.Command.WASH:
					%ThoughtBubbleLabel.text = "stinkyy..."
					pet_data.needs_data.wash()
			
			pet_data.command_data.finish_command.emit(cmd)
	)


func move_to_location(location: Vector2) -> void:
	actor.go_to_location(Vector3(location.x, 0, location.y))
	await actor.navigator.navigation_finished
