extends Control

@export var needs_data: NeedsData:
	set(value):
		needs_data = value
		connect_all()

@onready var activity := %ActivityRange as PillRange
@onready var comfort := %ComfortRange as PillRange
@onready var hunger := %HungerRange as PillRange
@onready var hygiene := %HygieneRange as PillRange
@onready var sleep := %SleepRange as PillRange


func _ready() -> void:
	connect_all()


func connect_all() -> void:
	if needs_data and is_inside_tree():
		needs_data.activity_changed.connect(
			func (val: float) -> void: activity.value = val
		)
		needs_data.comfort_changed.connect(
			func (val: float) -> void: comfort.value = val
		)
		needs_data.hunger_changed.connect(
			func (val: float) -> void: hunger.value = val
		)
		needs_data.hygiene_changed.connect(
			func (val: float) -> void: hygiene.value = val
		)
		needs_data.sleepy_changed.connect(
			func (val: float) -> void: sleep.value = val
		)
		update_values()


func update_values() -> void:
	activity.value = needs_data.activity
	comfort.value = needs_data.comfort
	hunger.value = needs_data.hunger
	hygiene.value = needs_data.hygiene
	sleep.value = needs_data.sleepy
	
