extends VBoxContainer

@export var personality_data: PersonalityData

@onready var range_bank := %BankRange as PillRange
@onready var range_active := %ActiveRange as PillRange
@onready var range_clean := %CleanRange as PillRange
@onready var range_playful := %PlayfulRange as PillRange
@onready var range_smart := %SmartRange as PillRange
@onready var range_social := %SocialRange as PillRange
@onready var ranges := [range_active, range_clean, range_playful, range_smart, range_social]
@onready var random_button := %RandomPersonalityButton as Button


func _ready() -> void:
	for node in ranges:
		node.value_changed.connect(
			func(_value):
				var total := get_bank_total()
				range_bank.value = total
				if total < 0: node.value += total
		)
	
	random_button.pressed.connect(
		func() -> void:
			personality_data.generate_random(false, false)
			update_ranges()
	)


func update_ranges() -> void:
	# Update from PetData
	var range_values := {
		range_active: personality_data.active,
		range_clean: personality_data.clean,
		range_playful: personality_data.playful,
		range_smart: personality_data.smart,
		range_social: personality_data.social
	}
	for node in range_values.keys():
		node.value = range_values[node]


func get_bank_total() -> int:
	var total: int = 15
	for node in ranges: total -= node.value as int
	return total


func validate() -> bool:
	return get_bank_total() < 5
