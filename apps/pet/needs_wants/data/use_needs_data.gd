class_name UseNeedsData
extends Object

var pet_data: PetData
var use_personality_data: UsePersonalityData

var activity: float:
	get: return pet_data.needs_data.activity
var comfort: float:
	get: return pet_data.needs_data.comfort
var hunger: float:
	get: return pet_data.needs_data.hunger
var hygiene: float:
	get: return pet_data.needs_data.hygiene
var sleepy: float:
	get: return pet_data.needs_data.sleepy


func _init(pet_data_value: PetData) -> void:
	pet_data = pet_data_value
	use_personality_data = UsePersonalityData.new(pet_data)


var overall_state: float:
	get:
		var primary_needs_state: float = (activity + hunger + sleepy) / 3.0
		var secondary_needs_state: float = (comfort + hygiene) / 2.0
		
		return lerpf(primary_needs_state, secondary_needs_state, 0.25)


var activity_threshold: float:
	get:
		var threshold := 0.25
		
		# `active` and `playful` attributes are correlated
		# more active or playful animals seek to fulfill their activity need
		# more quickly (at a higher threshold)
		threshold += pet_data.personality_data.active_percent * 0.25
		threshold += pet_data.personality_data.playful_percent * 0.25
		
		if use_personality_data.is_wild():
			threshold += 0.1
#
		return get_tolerance_threshold(threshold)


var comfort_threshold: float:
	get:
		var threshold := 0.5
		
		if use_personality_data.is_lazy():
			threshold += 0.1
		
		return get_tolerance_threshold(threshold)


var hunger_threshold: float:
	get:
		var threshold := 0.5
		
		if use_personality_data.is_foodie() or use_personality_data.is_lazy():
			threshold += 0.1
		
		return get_tolerance_threshold(threshold)


var hygiene_threshold: float:
	get:
		var threshold := 0.25
		
		# `clean` attribute is correlated
		# more clean animals will seek to fulfill their hygiene need at a higher threshold
		threshold += pet_data.personality_data.clean_percent * 0.5
		
		return get_tolerance_threshold(threshold)


var sleepy_threshold: float:
	get:
		var threshold := 0.5
		
		if use_personality_data.is_lazy():
			threshold += 0.1
		
		return get_tolerance_threshold(threshold)


func get_tolerance_threshold(start: float) -> float:
	var threshold := start
	
	# stubborn and wild animals don't fulfill their needs as fast
	if use_personality_data.is_stubborn() or use_personality_data.is_wild():
		threshold -= 0.1
	
	return clamp(threshold, 0.1, 0.9)


func are_needs_ok() -> Dictionary:
	return {
		NeedsData.Need.ACTIVITY: is_activity_ok(),
		NeedsData.Need.COMFORT: is_comfort_ok(),
		NeedsData.Need.HUNGER: is_hunger_ok(),
		NeedsData.Need.HYGIENE: is_hygiene_ok(),
		NeedsData.Need.SLEEPY: is_sleepy_ok(),
	}


func is_activity_ok() -> bool:
	return activity > activity_threshold


func is_comfort_ok() -> bool:
	return comfort > comfort_threshold


func is_hunger_ok() -> bool:
	return hunger > hunger_threshold


func is_hygiene_ok() -> bool:
	return hygiene > hygiene_threshold


func is_sleepy_ok() -> bool:
	return sleepy > sleepy_threshold


func debug_string() -> String:
	return DictRef.format({
		needs = {
			activity = activity,
			comfort = comfort,
			hunger = hunger,
			hygiene = hygiene,
			sleepy = sleepy,
		},
		thresholds = {
			activity_threshold = activity_threshold,
			comfort_threshold = comfort_threshold,
			hunger_threshold = hunger_threshold,
			hygiene_threshold = hygiene_threshold,
			sleepy_threshold = sleepy_threshold,
		}
	})
