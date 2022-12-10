class_name ModalController
extends Control
@icon("modal.svg")

signal opening
signal opened
signal closing
signal closed

enum Side {
	LEFT,
	RIGHT,
	TOP,
	BOTTOM
}

const BackdropButton := preload("res://interface/components/backdrop_button.tscn")

@export var target: Control
@export var enter_from: Side
@export var exit_to: Side

@export var start_open: bool = false
@export var use_backdrop: bool = true
@export var use_backdrop_blur: bool = true

## Automatically open the modal if the target scene is the current scene
@export var open_if_current_scene: bool = true

@onready var start_anchor_top: float = target.anchor_top
@onready var start_anchor_right: float = target.anchor_right
@onready var start_anchor_bottom: float = target.anchor_bottom
@onready var start_anchor_left: float = target.anchor_left
@onready var start_anchors: Dictionary:
	get: return {
		top = start_anchor_top,
		right = start_anchor_right,
		bottom = start_anchor_bottom,
		left = start_anchor_left
	}

@onready var duration: float = Settings.anim_duration(0.5)

@onready var backdrop_button := BackdropButton.instantiate() if use_backdrop else null

var is_open: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not start_open:
		target.modulate.a = 0
		await RenderingServer.frame_post_draw
		reset_to_before_enter()
	else: is_open = true
	
	if use_backdrop:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		backdrop_button.start_open = start_open
		backdrop_button.show_behind_parent = true
		backdrop_button.use_blur = use_backdrop_blur
		add_child(backdrop_button)
		backdrop_button.connect_to(self)
	
	if open_if_current_scene:
		var tree := get_tree()
		if target == tree.current_scene or target.get_parent() == tree.current_scene: 
			await tree.create_timer(0.5).timeout
			open()


func reset_to_before_enter() -> void:
	reset_anchors_to_side(enter_from)


func reset_to_after_exit() -> void:
	reset_anchors_to_side(exit_to)


func reset_anchors_to_side(side: Side) -> void:
	var anchors := get_target_anchor_positions(side)
	target.anchor_top = anchors.top
	target.anchor_right = anchors.right
	target.anchor_bottom = anchors.bottom
	target.anchor_left = anchors.left


func get_target_anchor_positions(to_side: Side) -> Dictionary:
	var anchors := {
		top = start_anchor_top,
		right = start_anchor_right,
		bottom = start_anchor_bottom,
		left = start_anchor_left
	}
	match to_side:
		Side.TOP:
			anchors.top = -1.0
			anchors.bottom = 0.0
		Side.RIGHT:
			anchors.right = 2.0
			anchors.left = 1.0
		Side.BOTTOM:
			anchors.top = 1.0
			anchors.bottom = 2.0
		Side.LEFT:
			anchors.left = -1.0
			anchors.right = 0.0
	return anchors


func open() -> void:
	if not is_open:
		opening.emit()
		reset_to_before_enter()
		
		var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		for side in start_anchors.keys():
			tween.tween_property(target, "anchor_" + side, float(start_anchors[side]), duration)
		
		tween.tween_property(target, "modulate:a", 1.0, duration)
		await tween.finished
		
		is_open = true
		opened.emit()


func close() -> void:
	if is_open:
		closing.emit()
		
		var target_anchors := get_target_anchor_positions(exit_to)
		var tween := create_tween().set_parallel().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		for side in target_anchors.keys():
			tween.tween_property(target, "anchor_" + side, target_anchors[side], duration)
		
		tween.tween_property(target, "modulate:a", 0.0, duration)
		await tween.finished
		
		is_open = false
		closed.emit()
