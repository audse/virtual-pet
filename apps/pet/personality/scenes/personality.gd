extends Control

@export var personality_data: PersonalityData:
	set(value):
		personality_data = value
		connect_all()

@onready var active := %ActiveRange as PillRange
@onready var clean := %CleanRange as PillRange
@onready var playful := %PlayfulRange as PillRange
@onready var smart := %SmartRange as PillRange
@onready var social := %SocialRange as PillRange

@onready var traits := %TraitsContainer as HFlowContainer
@onready var fave_food := %FaveFoodLabel as Label
@onready var fave_color := %FaveColorLabel as Label
@onready var fave_place := %FavePlaceLabel as Label


func _ready() -> void:
	connect_all()


func connect_all() -> void:
	if personality_data and is_inside_tree():
		personality_data.active_changed.connect(
			func (val: int) -> void: active.value = val
		)
		personality_data.clean_changed.connect(
			func (val: int) -> void: clean.value = val
		)
		personality_data.playful_changed.connect(
			func (val: int) -> void: playful.value = val
		)
		personality_data.smart_changed.connect(
			func (val: int) -> void: smart.value = val
		)
		personality_data.social_changed.connect(
			func (val: int) -> void: social.value = val
		)
		update_values()


func update_values() -> void:
	active.value = personality_data.active
	clean.value = personality_data.clean
	playful.value = personality_data.playful
	smart.value = personality_data.smart
	social.value = personality_data.social
	
	for child in traits.get_children(): child.queue_free()
	for t in personality_data.traits_data.traits:
		traits.add_child(Ui.tag(TraitsData.get_trait_name(t)))
	
	fave_food.text = personality_data.favorites_data.get_fave_food_name()
	fave_color.text = personality_data.favorites_data.get_fave_color_name()
	fave_place.text = personality_data.favorites_data.get_fave_place_name()
