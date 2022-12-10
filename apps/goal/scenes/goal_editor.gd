extends Control


@export var goal := GoalData.new()

@onready var file_dialog: FileDialog = %FileDialog
@onready var activation := {
	checkbox = {
		on_date = %ActivationOnDateCheckbox,
		default = %ActivationImmediateCheckbox
	},
	checkboxes = [%ActivationOnDateCheckbox, %ActivationImmediateCheckbox],
	year = %ActivationYearSpinBox,
	season = %ActivationSeasonOptionButton,
	month = %ActivationMonthOptionButton,
	date = %ActivationDateSpinBox,
	hour = %ActivationYearSpinBox,
	minute = %ActivationMinuteSpinBox,
	am_pm = %ActivationAmPmOptionButton,
}
@onready var expiration := { 
	checkbox = {
		on_date = %ExpirationOnDateCheckbox,
		after = %ExpirationAfterCheckbox,
		default = %ExpirationNeverCheckbox,
	},
	checkboxes = [%ExpirationAfterCheckbox, %ExpirationOnDateCheckbox, %ExpirationNeverCheckbox],
	year = %ExpirationYearSpinBox,
	season = %ExpirationSeasonOptionButton,
	month = %ExpirationMonthOptionButton,
	date = %ExpirationDateSpinBox,
	hour = %ExpirationYearSpinBox,
	minute = %ExpirationMinuteSpinBox,
	am_pm = %ExpirationAmPmOptionButton,
	
	amount = %ExpirationAfterAmountSpinBox,
	increment = %ExpirationAfterIncrementOptionButton
}

var activation_is_immediate: bool:
	get: return activation.checkbox.default.button_pressed

var expiration_is_never: bool:
	get: return expiration.checkbox.default.button_pressed

var expiration_is_relative: bool:
	get: return expiration.checkbox.after.button_pressed

var selected_expiration_increment: String:
	set(value): expiration.increment.select(find_item_by_text(expiration.increment, value))
	get: return expiration.increment.get_item_text(expiration.increment.selected).to_lower()


func _ready() -> void:
	for source in GoalData.Source.keys():
		var source_name: String = source.left(1).to_upper() + source.right(-1).to_lower()
		%SourceOptionButton.add_item(source_name, GoalData.Source[source])
	for item in BuyData.objects: %ObjectiveItemIdButton.add_item(item.id)
	for category in BuyData.categories: %ObjectiveCategoryIdButton.add_item(category.id)
	
	for checkbox in activation.checkboxes:
		checkbox.pressed.connect(update_disable_activation_fields.bind(checkbox))
	
	for checkbox in expiration.checkboxes:
		checkbox.pressed.connect(update_disable_expiration_fields.bind(checkbox))
	
	%UseInGameClockToggle.toggled.connect(
		func(value: bool) -> void:
			for button in [activation.season, expiration.season]: button.visible = value
			for button in [activation.month, expiration.month]: button.visible = not value
	)
	
	var area := Utils.get_display_area(self)
	
	file_dialog.size = area.size * Vector2(0.75, 0.5)
	file_dialog.position = area.size / 2 - Vector2(file_dialog.size) / 2
	
	%SaveButton.pressed.connect(
		func() -> void:
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			file_dialog.ok_button_text = "Save"
			file_dialog.show()
	)
	
	%OpenButton.pressed.connect(
		func() -> void:
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			file_dialog.ok_button_text = "Open"
			file_dialog.show()
	)
	
	file_dialog.file_selected.connect(
		func(path: String) -> void:
			if file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE: open_goal(path)
			else: save_goal(path)
	)
	
	goal.activation = int(Time.get_unix_time_from_system())
	goal.expiration = goal.activation
	
	update_activation_fields_from_data()
	update_expiration_fields_from_data()


func find_item_by_text(node: OptionButton, text: String) -> int:
	for i in node.item_count:
		if text == node.get_item_text(i): return i
	return -1


func update_fields_from_data() -> void:
	update_identity_fields_from_data()
	update_objective_fields_from_data()
	update_reward_fields_from_data()
	update_activation_fields_from_data()
	update_expiration_fields_from_data()


func update_data_from_fields() -> void:
	update_data_from_objective_fields() # must come first
	update_data_from_identity_fields()
	update_data_from_activation_fields()
	update_expiration_fields_from_data()


func update_identity_fields_from_data() -> void:
	%TitleLineEdit.text = goal.display_title
	%DescriptionLineEdit.text = goal.description
	%SourceOptionButton.select(goal.source)
	%UseInGameClockToggle.button_pressed = goal.uses_in_game_clock
	

func update_data_from_identity_fields() -> void:
	goal.display_title = %TitleLineEdit.text
	goal.description = %DescriptionLineEdit.text
	goal.source = %SourceOptionButton.selected
	goal.uses_in_game_clock = %UseInGameClockToggle.button_pressed


func update_objective_fields_from_data() -> void:
	%ObjectiveOptionButton.select(
		0 if goal is SellGoalData 
		else 1 if goal is CollectGoalData 
		else 2 if goal is CuddleGoalData 
		else -1
	)
	if goal is CollectGoalData or goal is SellGoalData:
		%ObjectiveItemIdButton.select(find_item_by_text(%ObjectiveItemIdButton, goal.one_item) if goal.one_item else 0)
		%ObjectiveCategoryIdButton.select(find_item_by_text(%ObjectiveCategoryIdButton, goal.any_item_in_category) if goal.any_item_in_category else 0)
	else:
		%ObjectiveItemIdButton.disabled = true
		%ObjectiveCategoryIdButton.disabled = true
	
	%ObjectiveAmountSpinBox.value = goal.total


func update_data_from_objective_fields() -> void:
	match %ObjectiveOptionButton.selected:
		0: goal = SellGoalData.new()
		1: goal = CollectGoalData.new()
		2: goal = CuddleGoalData.new()
	
	var item_id: String = %ObjectiveItemIdButton.get_item_text(%ObjectiveItemIdButton.selected)
	var category_id: String = %ObjectiveCategoryIdButton.get_item_text(%ObjectiveCategoryIdButton.selected)
	if item_id != "None" and "one_item" in goal: goal.one_item = item_id
	if category_id != "None" and "any_item_in_category" in goal: goal.any_item_in_category = category_id
	goal.total = %ObjectiveAmountSpinBox.value


func update_reward_fields_from_data() -> void:
	%RewardAmountSpinBox.value = goal.reward.fate


func update_data_from_reward_fields() -> void:
	goal.reward.fate = %RewardAmountSpinBox.value


func update_activation_fields_from_data() -> void:
	activation.checkbox.on_date.button_pressed = goal.activation != -1
	activation.checkbox.default.button_pressed = goal.activation == -1
	update_disable_activation_fields(
		activation.checkbox.default if activation_is_immediate
		else activation.checkbox.on_date
	)
	set_timestamp(activation, goal.activation)


func update_data_from_activation_fields() -> void:
	goal.activation = (
		get_timestamp(activation)
		if not activation_is_immediate
		else -1
	)


func update_expiration_fields_from_data() -> void:
	expiration.checkbox.after.button_pressed = goal.expiration != -1 and goal.expiration_is_relative
	expiration.checkbox.on_date.button_pressed = goal.expiration != -1 and not goal.expiration_is_relative
	expiration.checkbox.default.button_pressed = goal.expiration == -1
	update_disable_expiration_fields(
		expiration.checkbox.after if expiration_is_relative
		else expiration.checkbox.on_date if not expiration_is_never
		else expiration.checkbox.default
	)
	if goal.expiration_is_relative: select_relative_expiration()
	else: set_timestamp(expiration, goal.expiration)


func update_data_from_expiration_fields() -> void:
	goal.expiration = (
		get_relative_timestamp(expiration) if expiration_is_relative
		else get_timestamp(expiration) if not expiration_is_never
		else -1
	)


func select_relative_expiration() -> void:
	var date: Dictionary = (
		Dates.from_timestamp(goal.expiration) if goal.uses_in_game_clock
		else Dates.from_unix_timestamp(goal.expiration)
	)
	selected_expiration_increment = (
		"years" if date.year > 0
		else "seasons" if date.seasons > 0
		else "months" if date.months > 0
		else "days" if date.days > 0
		else "hours" if date.hours > 0
		else "minutes"
	)
	expiration.amount.value = date[selected_expiration_increment]


func update_disable_date_fields(fields: Dictionary, disabled: bool) -> void:
	for button in ["month", "season", "am_pm", "increment"]:
		if button in fields: fields[button].disabled = disabled
	for spinbox in ["date", "year", "hour", "minute", "amount"]:
		if spinbox in fields: fields[spinbox].editable = not disabled


func update_disable_activation_fields(selected: CheckBoxButton) -> void:
	for checkbox in activation.checkboxes: checkbox.button_pressed = false
	selected.button_pressed = true
	update_disable_date_fields(activation, activation_is_immediate)


func update_disable_expiration_fields(selected: CheckBoxButton) -> void:
	for checkbox in expiration.checkboxes: checkbox.button_pressed = false
	selected.button_pressed = true
	
	update_disable_date_fields(expiration, selected != expiration.checkbox.on_date)
	
	var after_date_disabled = selected != expiration.checkbox.after
	expiration.amount.editable = not after_date_disabled
	expiration.increment.disabled = after_date_disabled


func get_timestamp(fields: Dictionary) -> int:
	var date := {}
	for field in ["year", "day", "hour", "minute"]:
		date[field] = fields[field].value
		date[field + "s"] = fields[field].value
	for option in ["am_pm", "month", "season"]:
		date[option] = fields[option].selected
	if date.am_pm == 1:
		date.hour += 12
		date.hours += 12
	date.month += 1
	if goal.uses_in_game_clock: return Dates.get_timestamp(date)
	else: return Time.get_unix_time_from_datetime_dict(date)


func get_relative_timestamp(fields: Dictionary) -> int:
	var date := {}
	if "amount" in fields and "increment" in fields: 
		date[fields.increment.get_item_text(fields.increment.selected)] = fields.amount.value
	if goal.uses_in_game_clock: return Dates.get_timestamp(date)
	else: return Time.get_unix_time_from_datetime_dict(date)


func set_timestamp(fields: Dictionary, timestamp: int) -> void:
	var date: Dictionary = (
		Dates.from_timestamp(timestamp) if goal.uses_in_game_clock
		else Dates.from_unix_timestamp(timestamp, { reset_year = goal.uses_in_game_clock })
	)
	for option in ["season", "month", "am_pm"]:
		if option + "s" in date and option in fields:
			var value: int = date[option + "s"]
			fields[option].select(value)
	for field in ["year", "day", "hour", "minute"]:
		if field + "s" in date and field in fields:
			var value: int = date[field + "s"]
			fields[field].value = value
	fields.am_pm.select(0 if fields.hour.value < 12 else 1)


func save_goal(path: String) -> void:
	update_data_from_objective_fields()
	update_data_from_identity_fields()
	update_data_from_activation_fields()
	update_expiration_fields_from_data()
	
	if not ".tres" in path and not ".res" in path: path += ".tres"
	ResourceSaver.save(goal, path)


func open_goal(path: String) -> void:
	var data = ResourceLoader.load(path)
	if data is GoalData: goal = data
	update_fields_from_data()
