class_name UsePetData
extends Object

var pet_data: PetData


## `obedience` is the likelihood your pet will respond to your command.
## As your pet becomes happier, their obedience will grow.
var obedience: float:
	get: return lerp(pet_data.life_happiness, UseNeedsData.new(pet_data).overall_state, 0.25)


var happiness: float:
	get: return lerp(pet_data.life_happiness, UseNeedsData.new(pet_data).overall_state, 0.75)


func _init(pet_data_value: PetData) -> void:
	pet_data = pet_data_value


func will_obey_command() -> bool:
	return randf_range(0, obedience + 0.25) > 0.25


func use_object(object: WorldObjectData, command: CommandData.Command) -> void:
	# If the current pet owns the given object, their needs are fulfilled a little faster
	var is_owner: bool = (
		object.owner.get_rid() == pet_data.get_rid() 
		if object.owner 
		else false
	)
	if object.can_use():
		object.use()
		match command:
			CommandData.Command.PLAY: pet_data.needs_data.play(is_owner)
			CommandData.Command.LOUNGE: pet_data.needs_data.lounge(is_owner)
			CommandData.Command.EAT: pet_data.needs_data.eat(is_owner)
			CommandData.Command.WASH: pet_data.needs_data.wash(is_owner)
			CommandData.Command.SLEEP: pet_data.needs_data.sleep(is_owner)
