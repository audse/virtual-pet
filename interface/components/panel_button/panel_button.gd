@tool
class_name PanelButton
extends Button
@icon("panel_button.svg")

signal opening
signal opened
signal closing
signal closed

@export var container_path: NodePath

@onready var container: Container = get_node_or_null(container_path)
var panel: Panel = null

@onready var styleboxes := {
	normal = get_theme_stylebox("normal", "Button"),
	pressed = get_theme_stylebox("pressed", "Button"),
	hover = get_theme_stylebox("hover", "Button")
}

@onready var start_min_size: Vector2 = custom_minimum_size
@onready var start_size: Vector2 = size
@onready var container_scale: Vector2 = container.scale if container else Vector2.ONE

var container_start_scale: Vector2:
	get: 
		match anchors_preset:
			PRESET_TOP_LEFT, PRESET_LEFT_WIDE, PRESET_CENTER_LEFT, PRESET_BOTTOM_LEFT, PRESET_TOP_RIGHT, PRESET_BOTTOM_RIGHT, PRESET_CENTER_RIGHT, PRESET_RIGHT_WIDE:
				return Vector2(0, 0.75)
			PRESET_CENTER: return Vector2.ZERO
			_: return Vector2(0.75, 0)


var panel_disabled: bool = false


func _ready() -> void:
	_reset()
	toggled.connect(toggle)


func toggle(is_opened: bool) -> void:
	if is_opened: open()
	else: close()


func open() -> void:
	_reset()
	if not panel_disabled:
		opening.emit()
		(
			AnimBuilder.new(self)
				.setup({ "custom_minimum_size": max(size, custom_minimum_size), "text": "", "icon": null })
				.keyframe("open", 0.25)
				.self_fade_out()
				.prop("custom_minimum_size", { open = container.size })
				.tear_down({ "text": text, "icon": icon })
				.complete()
		)
		if container:
			(
				AnimBuilder.new(container)
					.setup({ "scale": container_start_scale, "visible": true, "rotation": deg2rad(2.0) })
					.keyframe("open", 0.25, Tween.EASE_OUT, Tween.TRANS_SINE)
					.keyframe("settle", 0.25, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
					.fade_in()
					.prop("scale", { 
						open = container_scale * 1.05,
						settle = container_scale
					})
					.prop("rotation", { 
						open = deg2rad(-0.5),
						settle = 0.0,
					})
					.complete()
			)
		
		if panel:
			add_theme_stylebox_override("pressed", _empty_stylebox(styleboxes.pressed))
			await (
				AnimBuilder.new(panel)
					.setup({ "size": start_size, "visible": true, "rotation": deg2rad(2.0), })
					.keyframe("open", 0.25, Tween.EASE_OUT, Tween.TRANS_SINE)
					.keyframe("settle", 0.15, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
					.prop("size", { 
						open = container.size * 1.05,
						settle = container.size 
					})
					.prop("rotation", { 
						open = deg2rad(-0.5),
						settle = 0.0,
					})
					.complete()
			)
		opened.emit()


func close() -> void:
	button_pressed = false
	_reset()
	if not panel_disabled:
		closing.emit()
		add_theme_stylebox_override("normal", _empty_stylebox(styleboxes.normal))
		add_theme_stylebox_override("hover", _empty_stylebox(styleboxes.normal))
		(
			AnimBuilder.new(self)
				.keyframe("close", 0.25)
				.self_fade_in()
				.prop("custom_minimum_size", { close = start_min_size })
				.tear_down({ "text": text, "icon": icon })
				.complete()
		)
		
		if container:
			(
				AnimBuilder.new(container)
					.keyframe("anticipation", 0.1, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
					.keyframe("close", 0.15, Tween.EASE_IN, Tween.TRANS_SINE)
					.fade_out()
					.prop("scale", { 
						anticipation = container.scale * 1.05,
						close = container_start_scale
					})
					.tear_down({ "visible": false })
					.complete()
			)
		
		if panel:
			await get_tree().create_timer(0.05).timeout
			await (
				AnimBuilder.new(panel)
					.keyframe("anticipation", 0.1, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
					.keyframe("close", 0.15, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
					.prop("size", { 
						anticipation = panel.size * 1.05,
						close = start_size,
					})
					.tear_down({ "visible": false })
					.complete()
			)
		
		for style in styleboxes:
			add_theme_stylebox_override(style, styleboxes[style])
		closed.emit()


func _empty_stylebox(box: StyleBox) -> StyleBox:
	var new_stylebox := StyleBox.new()
	
	# keep content margin the same to avoid jumping
	for margin in ["top", "right", "bottom", "left"]:
		var margin_name: String = "content_margin_" + margin
		new_stylebox[margin_name] = box[margin_name]
	
	return new_stylebox


func _reset():
	toggle_mode = true
	keep_pressed_outside = true
	
	if container:
		container.pivot_offset = start_size / 2
	
	if panel:
		panel.pivot_offset = start_size / 2
	
	_make_panel()


func _make_panel() -> void:
	if not panel:
		panel = Panel.new()
		add_child(panel)
		move_child(panel, 0)
		panel.show_behind_parent = true
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_theme_stylebox_override(
			"panel", 
			get_theme_stylebox("pressed", "Button")
		)


func _remake_panel() -> void:
	if panel: panel.queue_free()
	_make_panel()
