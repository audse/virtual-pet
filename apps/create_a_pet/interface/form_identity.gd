extends VBoxContainer

@export var pet_data: PetData:
	set(value):
		pet_data = value
		update()

@onready var year: int = Datetime.data.year

@onready var field_name := %NameField as LineEdit
@onready var field_bday_season := %BirthdaySeasonField as OptionButton
@onready var field_bday_date = %BirthdayDateField as SpinBox

@onready var random_button_name := %RandomNameButton as Button

var name_presets: Array[String] = load_name_presets()

func _ready() -> void:
	field_name.text_changed.connect(
		func(new_name: String) -> void: pet_data.name = new_name
	)
	field_bday_season.item_selected.connect(
		func(_i) -> void: pet_data.birthday = get_birthday()
	)
	field_bday_date.value_changed.connect(
		func(value: int) -> void: 
			pet_data.birthday = get_birthday()
			field_bday_date.suffix = Dates.get_date_suffix(value)
	)
	(%BirthdayYearLabel as Label).text = "Year {year}".format({ year = year + 1 })
	(%RandomBirthdayButton as Button).pressed.connect(randomize_birthday)
	
	random_button_name.disabled = name_presets.size() == 0
	random_button_name.pressed.connect(randomize_name)


func update() -> void:
	if is_inside_tree():
		update_birthday_from_data()


func update_birthday_from_data() -> void:
	var birthday: Dictionary = Dates.from_timestamp(pet_data.birthday)
	field_bday_season.select(birthday.seasons)
	field_bday_date.value = birthday.days + birthday.weeks * 7
	field_bday_date.suffix = Dates.get_date_suffix(field_bday_date.value)


func load_name_presets() -> Array[String]:
	var name_file := FileAccess.open("res://apps/create_a_pet/data/names.json", FileAccess.READ)
	var contents: Dictionary = JSON.parse_string(name_file.get_as_text())
	var language := OS.get_locale_language()
	if language in contents: return contents[language]
	return []


func randomize_birthday() -> void:
	field_bday_season.selected = randi_range(0, 3)
	field_bday_date.value = randi_range(0, 28)


func randomize_name() -> void:
	var num_presets := name_presets.size()
	if num_presets: field_name.text = name_presets[randi_range(0, num_presets - 1)]


func get_birthday() -> int:
	return Dates.get_timestamp({
		years = year,
		seasons = clamp(field_bday_season.selected, 0, 3),
		days = field_bday_date.value - 1
	})


func validate() -> bool:
	if field_name.text.length() == 0: 
		return false
	return true
