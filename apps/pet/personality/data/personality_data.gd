class_name PersonalityData
extends Resource

signal active_changed(value: int)
signal clean_changed(value: int)
signal playful_changed(value: int)
signal smart_changed(value: int)
signal social_changed(value: int)

signal attribute_changed(attribute: String, value: int)


@export_range(0, 5, 1) var active := 0:
	set(value):
		active = value
		active_changed.emit(active)
		attribute_changed.emit("active", value)
		emit_changed()

@export_range(0, 5, 1) var clean := 0:
	set(value):
		clean = value
		clean_changed.emit(clean)
		attribute_changed.emit("clean", value)
		emit_changed()

@export_range(0, 5, 1) var playful := 0:
	set(value):
		playful = value
		playful_changed.emit(playful)
		attribute_changed.emit("playful", value)
		emit_changed()

@export_range(0, 5, 1) var smart := 0:
	set(value):
		smart = value
		smart_changed.emit(smart)
		attribute_changed.emit("smart", value)
		emit_changed()

@export_range(0, 5, 1) var social := 0:
	set(value):
		social = value
		social_changed.emit(social)
		attribute_changed.emit("social", value)
		emit_changed()

@export var favorites_data := FavoritesData.new()
@export var traits_data := TraitsData.new()

var active_percent: float:
	get: return (active as float) / 5.0
var clean_percent: float:
	get: return (clean as float) / 5.0
var playful_percent: float:
	get: return (playful as float) / 5.0
var smart_percent: float:
	get: return (smart as float) / 5.0
var social_percent: float:
	get: return (social as float) / 5.0


func _init(
	is_random := true,
	active_value := active,
	clean_value := clean,
	playful_value := playful,
	smart_value := smart,
	social_value := social,
	favorites_data_value := favorites_data,
	traits_data_value := traits_data,
) -> void:
	if is_random:
		generate_random()
	else:
		active = active_value
		clean = clean_value
		playful = playful_value
		smart = smart_value
		social = social_value
		favorites_data = favorites_data_value
		traits_data = traits_data_value


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
	
	favorites_data.generate_random()
	traits_data.generate_random()
