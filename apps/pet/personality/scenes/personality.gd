extends Control

@export var personality_data: PersonalityData

@onready var active := %ActiveRange as PillRange
@onready var clean := %CleanRange as PillRange
@onready var playful := %PlayfulRange as PillRange
@onready var smart := %SmartRange as PillRange
@onready var social := %SocialRange as PillRange


func _ready() -> void:
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
	
