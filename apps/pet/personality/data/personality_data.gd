class_name PersonalityData
extends Resource

signal active_changed(value: int)
signal clean_changed(value: int)
signal playful_changed(value: int)
signal smart_changed(value: int)
signal social_changed(value: int)


@export_range(0, 5, 1) var active := 0:
	set(value):
		active = value
		active_changed.emit(active)

@export_range(0, 5, 1) var clean := 0:
	set(value):
		clean = value
		clean_changed.emit(clean)

@export_range(0, 5, 1) var playful := 0:
	set(value):
		playful = value
		playful_changed.emit(playful)

@export_range(0, 5, 1) var smart := 0:
	set(value):
		smart = value
		smart_changed.emit(smart)

@export_range(0, 5, 1) var social := 0:
	set(value):
		social = value
		social_changed.emit(social)


func _init(
	is_random := true,
	active_value := active,
	clean_value := clean,
	playful_value := playful,
	smart_value := smart,
	social_value := social
) -> void:
	if is_random:
		generate_random()
	else:
		active = active_value
		clean = clean_value
		playful = playful_value
		smart = smart_value
		social = social_value


func generate_random() -> void:
	var points := 15
	
	# assign values in a random order (to not bias toward end)
	var indeces: Array = [0, 1, 2, 3, 4]
	indeces.shuffle()
	
	for index in indeces:
		
		var value := 0
		if points >= 5:
			value = Auto.Random.randi_range(0, 5)
			
			# value of 0 should be kinda rare, reroll it once
			if value == 0:
				value = Auto.Random.randi_range(0, 5)
			
			points -= value
		else:
			value = points
			points = 0
		
		# assign random value based on random index
		match index:
			0: active = value
			1: clean = value
			2: playful = value
			3: smart = value
			4: social = value
