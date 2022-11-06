extends Control

signal opening
signal opened
signal closing
signal closed

var is_open: bool = false:
	set(value):
		is_open = value
		if is_open: opened.emit()
		else: closed.emit()

@onready var use_24_hour_clock_toggle := %Use24HourClockToggle as ToggleSwitch

# Accessibility
@onready var limit_animations_toggle := %LimitAnimationsToggle as ToggleSwitch
@onready var font_size_item_list := %FontSizeItemList as ItemList

# Mods
@onready var enabled_mods_item_list := %EnabledModsItemList as ItemList


var duration: float:
	get: return (
		0.25 if not Settings.data.limit_animations
		else 0.0
	)


func _ready():
	reset()
	
	use_24_hour_clock_toggle.pressed.connect(
		func() -> void: Settings.data.use_24_hour_clock = use_24_hour_clock_toggle.button_pressed
	)
	
	limit_animations_toggle.pressed.connect(
		func() -> void: Settings.data.limit_animations = limit_animations_toggle.button_pressed
	)
	
	font_size_item_list.item_selected.connect(
		func(size_index: int) -> void: Settings.data.font_size = size_index as SettingsData.SizeSetting
	)
	
	enabled_mods_item_list.item_clicked.connect(_on_mod_clicked)


func reset() -> void:
	use_24_hour_clock_toggle.button_pressed = Settings.data.use_24_hour_clock
	limit_animations_toggle.button_pressed = Settings.data.limit_animations
	font_size_item_list.select(Settings.data.font_size)
	font_size_item_list.ensure_current_is_visible()
	enabled_mods_item_list.clear()
	
	for mod in Modules.registered_modules.keys():
		var mod_index := enabled_mods_item_list.add_item(mod)
		if not mod in Settings.data.disabled_mods:
			enabled_mods_item_list.select(mod_index)
	
	anchor_top = 1.5
	anchor_bottom = 1.5	
	modulate.a = 0.0
	visible = true


func open() -> void:
	if not is_open:
		Datetime.data.paused = true
		reset()
		opening.emit()
		var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "anchor_top", 0.5, duration)
		tween.tween_property(self, "anchor_bottom", 0.5, duration)
		tween.tween_property(self, "modulate:a", 1.0, duration)
		await tween.finished
		is_open = true


func close() -> void:
	if is_open:
		closing.emit()
		var tween := create_tween().set_parallel().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "anchor_top", 1.5, duration)
		tween.tween_property(self, "anchor_bottom", 1.5, duration)
		tween.tween_property(self, "modulate:a", 0.0, duration)
		await tween.finished
		is_open = false
		Datetime.data.paused = Datetime.data.prev_pause_state


func _on_mod_clicked(mod_index: int, _at_pos, _mouse_button) -> void:
	var enabled_mods: Array[String] = (enabled_mods_item_list.get_selected_items() as Array[int]).map(
		func(mod_index: int) -> String: return enabled_mods_item_list.get_item_text(mod_index)
	)
	
	for mod in Modules.registered_modules.keys():
		if mod in enabled_mods: Settings.data.enable_mod(mod)
		else: Settings.data.disable_mod(mod)
