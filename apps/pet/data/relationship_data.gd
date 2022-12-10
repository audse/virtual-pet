class_name RelationshipData
extends SaveableResource

const MAX_FONDNESS_INCREMENT := 0.05

@export var pet_a: PetData
@export var pet_b: PetData

@export_range(0.0, 1.0) var fondness: float = 0.5:
	set(value):
		fondness = clampf(value, 0.0, 1.0)
		emit_changed()


func _init(pet_a_value: PetData = null, pet_b_value: PetData = null) -> void:
	if pet_a_value: pet_a = pet_a_value
	if pet_b_value: pet_b = pet_b_value


func involves(a: PetData, b: PetData = null) -> bool:
	if b: return (pet_a == a and pet_b == b) or (pet_a == b and pet_b == a)
	else: return pet_a == a or pet_b == a


func play_together(target: WorldObjectData) -> void:
	pet_a.command_data.start_command.emit(CommandData.PLAY_TOGETHER, target)
	pet_b.command_data.start_command.emit(CommandData.PLAY_TOGETHER, target)


func increase_fondness() -> void:
	fondness += randf_range(0.00, MAX_FONDNESS_INCREMENT)


func decrease_fondness() -> void:
	fondness -= randf_range(0.00, MAX_FONDNESS_INCREMENT)


func other(not_pet: PetData) -> PetData:
	if pet_a == not_pet: return pet_b
	else: return pet_a


func _get_dir() -> String:
	return "relationships"


static func load_relationships() -> void:
	for file in Utils.open_or_make_dir("user://relationships").get_files():
		ResourceQueue.queue(
			"user://relationships/" + file,
			func(_path: String, data: Resource) -> void:
				PetManager.relationships.append((data as RelationshipData).setup())
		)
