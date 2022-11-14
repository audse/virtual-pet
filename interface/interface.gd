extends Control

@onready var live_mode_button := %LiveModeButton as Button
@onready var buy_mode_button := %BuyModeButton as Button
@onready var build_mode_button := %BuildModeButton as Button

@onready var backdrop_button := %BackdropButton as Button
@onready var settings_button := %SettingsButton as Button
@onready var pause_button := %PauseButton as Button
@onready var fate_button := %FateButton as Button
@onready var goals_button := %GoalsButton as Button
@onready var datetime_label := %DatetimeLabel as TitleLabel
@onready var settings_menu := %SettingsMenu as Control
@onready var goals_menu := %GoalsMenu as Control
@onready var paused_overlay := %PausedOverlay as Panel
@onready var show_roof_button := %ShowRoofButton as Button
@onready var hide_roof_button := %HideRoofButton as Button

@onready var mode_buttons := {
	GameModeState.Mode.LIVE: live_mode_button,
	GameModeState.Mode.BUY: buy_mode_button,
	GameModeState.Mode.BUILD: build_mode_button,
}

var mode_button_colors := {
	GameModeState.Mode.LIVE: {
		normal = ColorRef.FUCHSIA_300,
		focus = ColorRef.FUCHSIA_300,
		pressed = ColorRef.FUCHSIA_300,
		hover = ColorRef.FUCHSIA_300,
	},
	GameModeState.Mode.BUY: {
		normal = ColorRef.FUCHSIA_300,
		focus = ColorRef.FUCHSIA_300,
		pressed = ColorRef.FUCHSIA_400,
		hover = ColorRef.FUCHSIA_200,
	},
	GameModeState.Mode.BUILD: {
		normal = ColorRef.INDIGO_300,
		focus = ColorRef.INDIGO_300,
		pressed = ColorRef.INDIGO_400,
		hover = ColorRef.INDIGO_200,
	},
}


func _ready() -> void:
	# Update fate display
	Fate.data.fate_changed.connect(update_fate_button)
	update_fate_button(Fate.data.fate)
	
	# Update datetime display
	Datetime.data.day_changed.connect(
		func(_day) -> void: update_datetime()
	)
	Datetime.data.time_changed.connect(
		func(_time) -> void: update_datetime()
	)
	Settings.data.use_24_hour_clock_changed.connect(
		func(_value) -> void: update_datetime()
	)
	update_datetime()
	
	# Connect paused overlay
	Datetime.data.time_paused.connect(open_paused_overlay)
	Datetime.data.time_unpaused.connect(close_paused_overlay)
	
	# Hide overlays
	for node in [backdrop_button, paused_overlay]:
		node.visible = false
		node.modulate.a = 0.0
	
	# Connect settings menu
	settings_button.pressed.connect(
		func() -> void:
			if settings_menu.is_open: settings_menu.close()
			else: 
				settings_menu.open()
				backdrop_button.pressed.connect(settings_menu.close, CONNECT_ONE_SHOT)
	)
	settings_menu.opening.connect(open_backdrop)
	settings_menu.closing.connect(close_backdrop)
	
	goals_button.pressed.connect(goals_menu.open)
	
	# Connect pause button
	pause_button.pressed.connect(
		func() -> void: 
			Datetime.data.paused = not Datetime.data.paused
	)
	
	live_mode_button.pressed.connect(
		func() -> void: Game.Mode.set_to(GameModeState.Mode.LIVE)
	)
	
	buy_mode_button.pressed.connect(
		func() -> void: Game.Mode.set_to(GameModeState.Mode.BUY)
	)
	
	build_mode_button.pressed.connect(
		func() -> void: Game.Mode.set_to(GameModeState.Mode.BUILD)
	)
	
	hide_roof_button.pressed.connect(
		func() -> void: Settings.data.hide_roofs = true
	)
	
	show_roof_button.pressed.connect(
		func() -> void: Settings.data.hide_roofs = false
	)
	
	Settings.data.hide_roofs_changed.connect(
		func(hide_roofs: bool) -> void:
			hide_roof_button.visible = not hide_roofs
			show_roof_button.visible = hide_roofs
	)
	
	Game.Mode.exit_state.connect(exit_mode)
	Game.Mode.enter_state.connect(enter_mode)
	enter_mode(Game.Mode.state)


func enter_mode(mode: int) -> void:
	var button: Button = mode_buttons[mode]
	var tween := button.create_tween().set_parallel().set_trans(Tween.TRANS_BACK)
	var duration := 0.25 if not Settings.data.limit_animations else 0.0
	tween.tween_property(button, "custom_minimum_size", Vector2(180.0, 180.0), duration)
	tween.tween_property(button, "size", Vector2(180.0, 180.0), duration)
	
	for state in mode_button_colors[Game.Mode.state].keys():
		button.add_theme_color_override(
			"icon_" + state + "_color",
			mode_button_colors[Game.Mode.state][state]
		)
	
	# Close the main menu when the Buy menu is open and the game window is small
	var area := Utils.get_display_area(self).size
	if (
		(mode == GameModeState.Mode.BUY and area.x < 2048)
		or mode ==  GameModeState.Mode.BUILD
	):
		%CloseButton.pressed.emit()


func exit_mode(mode: int) -> void:
	var button: Button = mode_buttons[mode]
	var tween := button.create_tween().set_parallel().set_trans(Tween.TRANS_BACK)
	var duration := 0.25 if not Settings.data.limit_animations else 0.0
	tween.tween_property(button, "custom_minimum_size", Vector2(140.0, 140.0), duration)
	tween.tween_property(button, "size", Vector2(140.0, 140.0), duration)
	for state in ["normal", "hover", "pressed"]:
		button.remove_theme_color_override("icon_" + state + "_color")
	
	if mode ==  GameModeState.Mode.BUILD:
		%OpenButton.pressed.emit()


func update_fate_button(value: int) -> void:
	fate_button.text = "       {0}".format([value])


func update_datetime() -> void:
	datetime_label.overline = Datetime.data.day_name.to_upper()
	datetime_label.title = Datetime.data.display_time


func open_backdrop() -> void:
	backdrop_button.visible = true
	var duration: float = 0.2 if not Settings.data.limit_animations else 0.0
	var tween := backdrop_button.create_tween()
	tween.tween_property(backdrop_button, "modulate:a", 1.0, duration)
	await tween.finished


func close_backdrop() -> void:
	var duration: float = 0.2 if not Settings.data.limit_animations else 0.0
	var tween := backdrop_button.create_tween()
	tween.tween_property(backdrop_button, "modulate:a", 0.0, duration)
	await tween.finished
	backdrop_button.visible = false


func open_paused_overlay() -> void:
	paused_overlay.visible = true
	var duration: float = 0.2 if not Settings.data.limit_animations else 0.0
	var tween := paused_overlay.create_tween()
	tween.tween_property(paused_overlay, "modulate:a", 1.0, duration)
	await tween.finished


func close_paused_overlay() -> void:
	var duration: float = 0.2 if not Settings.data.limit_animations else 0.0
	var tween := paused_overlay.create_tween()
	tween.tween_property(paused_overlay, "modulate:a", 0.0, duration)
	await tween.finished
	paused_overlay.visible = false
