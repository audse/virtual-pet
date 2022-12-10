class_name WantsData
extends Resource

enum Want {
	EAT_FAVORITE_FOOD,
	PLAY_IN_FAVORITE_PLACE,
	SLEEP_IN_FAVORITE_PLACE,
	LOUNGE_IN_FAVORITE_PLACE,
	EAT_IN_FAVORITE_PLACE,
	LOUNGE_WITH_FRIEND,
	GET_PATTED,
	ROLL_AROUND_ON_GROUND,
	EXPLORE,
	
	# [x] implemented
	EAT_RARE_FOOD,
	
	# [-] implemented, but untested
	PLAY_WITH_RARE_TOY,
	LOUNGE_ON_RARE_BED,
	SLEEP_ON_RARE_BED,
	PLAY_WITH_FRIEND,
}

signal wants_changed(new_wants: Array[Want])
signal want_fulfilled(want: Want)

const hunger_wants: Array[Want] = [
	Want.EAT_FAVORITE_FOOD, 
	Want.EAT_IN_FAVORITE_PLACE,
	Want.EAT_RARE_FOOD,
]

const sleepy_wants: Array[Want] = [
	Want.SLEEP_IN_FAVORITE_PLACE,
	Want.SLEEP_ON_RARE_BED,
]

const activity_wants: Array[Want] = [
	Want.PLAY_IN_FAVORITE_PLACE,
	Want.PLAY_WITH_FRIEND,
	Want.GET_PATTED,
	Want.EXPLORE,
	Want.PLAY_WITH_RARE_TOY,
]

const comfort_wants: Array[Want] = [
	Want.LOUNGE_IN_FAVORITE_PLACE,
	Want.GET_PATTED,
	Want.SLEEP_ON_RARE_BED,
	Want.LOUNGE_ON_RARE_BED,
	Want.LOUNGE_WITH_FRIEND,
]

const clean_wants: Array[Want] = [
	Want.ROLL_AROUND_ON_GROUND,
]

const misc_wants: Array[Want] = [
	Want.ROLL_AROUND_ON_GROUND,
	Want.GET_PATTED,
	Want.EXPLORE,
]


@export var wants: Array[Want] = []


func select_wants(pet_data: PetData) -> void:
	wants = []
	
	if not UseNeedsData.new(pet_data).is_activity_ok():
		add_wants(activity_wants)
	
	if not UseNeedsData.new(pet_data).is_hunger_ok():
		add_wants(hunger_wants)
	
	if not UseNeedsData.new(pet_data).is_sleepy_ok():
		add_wants(sleepy_wants)
	
	if not UseNeedsData.new(pet_data).is_comfort_ok():
		add_wants(comfort_wants)
	
	if not UseNeedsData.new(pet_data).is_hygiene_ok():
		add_wants(clean_wants)
	
	if len(wants) < 3:
		add_wants(misc_wants)
	
	wants.shuffle()
	wants.resize(3)
	
	wants_changed.emit(wants)
	emit_changed()


static func get_want_name(want: Want) -> String:
	return Want.find_key(want).replace("_", " ").to_lower()


func add_wants(new_wants: Array) -> void:
	for want in new_wants:
		if not wants.has(want): wants.append(want)


func fulfill_want(want: Want) -> void:
	print("Fulfilled want! ", WantsData.get_want_name(want))
	if wants.has(want):
		want_fulfilled.emit(want)
		wants.erase(want)
