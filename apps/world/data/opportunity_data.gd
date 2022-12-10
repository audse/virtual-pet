class_name OpportunityData
extends Resource
	
enum Objective {
	FULFILL_NEED,
	FULFILL_WANT,
	EXPRESS_PERSONALITY,
}

var nearby_pet: PetData
var nearby_object: WorldObjectData
var detail := {
	Objective.FULFILL_NEED: null,
	Objective.FULFILL_WANT: null,
	Objective.EXPRESS_PERSONALITY: null,
}


func _init(data: Dictionary = {}) -> void:
	for key in data.keys(): if key in self: self[key] = data[key]


func describe() -> String:
	var objectives := detail.keys() \
		.filter(func(key: Objective) -> bool: return detail[key] != null) \
		.map(func(objective: Objective) -> String: return Objective.find_key(objective))
	return (
		"[Pet]: {pet_name} \n"
		+ "[Object]: {object_id} \n"
		+ "[Objectives]: {objectives}" 
	).format({
		pet_name = nearby_pet.name if nearby_pet else "N/A",
		object_id = nearby_object.item_data.id if nearby_object else "N/A",
		objectives = objectives
	})


static func find_need_opportunity(pet: PetData) -> OpportunityData:
	var nearby_objects := WorldData.find_nearby_objects(pet.world_coord, 3)
	for object in nearby_objects:
		if not object.item_data.use_data: continue
		for need in object.item_data.use_data.fulfills_needs:
			if pet.needs_data.get_need(need) < 0.3: return OpportunityData.new({
				nearby_object = object,
				detail = { Objective.FULFILL_NEED: need }
			})
	return null


static func find_want_opportunity(pet: PetData, want: WantsData.Want) -> OpportunityData:
	match want:
		WantsData.Want.PLAY_WITH_FRIEND: return OpportunityData.find_play_with_friend_opportunity(pet)
		WantsData.Want.EAT_RARE_FOOD: return OpportunityData.find_nearby_rare_need_source_opportunity(pet, NeedsData.Need.HUNGER)
		WantsData.Want.PLAY_WITH_RARE_TOY: return OpportunityData.find_nearby_rare_need_source_opportunity(pet, NeedsData.Need.ACTIVITY)
		WantsData.Want.LOUNGE_ON_RARE_BED: return OpportunityData.find_nearby_rare_need_source_opportunity(pet, NeedsData.Need.COMFORT)
		WantsData.Want.SLEEP_ON_RARE_BED: return OpportunityData.find_nearby_rare_need_source_opportunity(pet, NeedsData.Need.SLEEPY)
	return null


static func find_play_with_friend_opportunity(pet: PetData) -> OpportunityData:
	var nearby_pets := WorldData.find_nearby_pets(pet.world_coord, 5) \
		.filter(func(friend: PetData) -> bool: return pet.is_friends_with(friend))
	var nearby_toy := WorldData.find_nearby_need_source(pet, NeedsData.Need.ACTIVITY, pet.world_coord, 5)
	if nearby_pets.size() and nearby_toy:
		return OpportunityData.new({
			nearby_pet = nearby_pets[0],
			nearby_object = nearby_toy,
			detail = { Objective.FULFILL_WANT: WantsData.Want.PLAY_WITH_FRIEND }
		})
	return null


static func find_nearby_rare_need_source_opportunity(pet: PetData, need: NeedsData.Need) -> OpportunityData:
	var nearby_objects: Array[WorldObjectData] = WorldData.find_all_nearby_need_sources(pet, need, pet.world_coord, 5)
	nearby_objects.sort_custom(
		func(a: WorldObjectData, b: WorldObjectData) -> bool:
			return a.item_data.rarity > b.item_data.rarity
	)
	if nearby_objects.size() and nearby_objects[0].item_data.is_rare:
		var want: WantsData.Want
		match need:
			NeedsData.Need.HUNGER: want = WantsData.Want.EAT_RARE_FOOD
			NeedsData.Need.SLEEPY: want = WantsData.Want.SLEEP_ON_RARE_BED
		return OpportunityData.new({
			nearby_object = nearby_objects[0],
			detail = { Objective.FULFILL_WANT: want }
		})
	return null
