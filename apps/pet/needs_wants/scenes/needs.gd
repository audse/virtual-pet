extends Control

@export var needs_data: Resource

@onready var activity := %ActivityRange as PillRange
@onready var comfort := %ComfortRange as PillRange
@onready var hunger := %HungerRange as PillRange
@onready var hygiene := %HygieneRange as PillRange
@onready var sleep := %SleepRange as PillRange


func _ready() -> void:
	needs_data.activity_changed.connect(
		func (val: int) -> void: activity.value = val
	)
	needs_data.comfort_changed.connect(
		func (val: int) -> void: comfort.value = val
	)
	needs_data.hunger_changed.connect(
		func (val: int) -> void: hunger.value = val
	)
	needs_data.hygiene_changed.connect(
		func (val: int) -> void: hygiene.value = val
	)
	needs_data.sleep_changed.connect(
		func (val: int) -> void: sleep.value = val
	)
	update_values()


func update_values() -> void:
	activity.value = needs_data.activity
	comfort.value = needs_data.comfort
	hunger.value = needs_data.hunger
	hygiene.value = needs_data.hygiene
	sleep.value = needs_data.sleep
	
