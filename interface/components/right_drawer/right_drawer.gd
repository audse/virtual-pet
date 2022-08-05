@tool
class_name RightDrawerComponent
extends Container
@icon("right_drawer.svg")

## Right after open starts, before animation is completed
signal opened

## After open animation is completed
signal is_open

## Right after close starts, before animation is completed
signal closed

## After close animation is completed
signal is_closed

const ANIMS: AnimationLibrary = preload("res://interface/components/right_drawer/right_drawer_animations.res")
const ANIM_LIB_NAME := "right_drawer_animations"
const PLAYER_NODE := "_RightDrawerAnimationPlayer"
const REF_RECT_NODE := "_RightDrawerReferenceRect"

const Anim := {
	OPEN = ANIM_LIB_NAME + "/SlideOpen",
	CLOSE = ANIM_LIB_NAME + "/SlideClose",
	RESET = ANIM_LIB_NAME + "/RESET",
	RESET_OPEN = ANIM_LIB_NAME + "/RESET_OPEN",
}


@export var show_reference_rect: bool = true:
	set(value):
		if ref_rect:
			show_reference_rect = value
			ref_rect.visible = value
			ref_rect.mouse_filter = MOUSE_FILTER_IGNORE


@export var test_open: bool = false:
	set(_value):
		if player:
			test_open = true
			player.play(Anim.RESET)
			await player.animation_finished
			player.play(Anim.OPEN)
			await player.animation_finished
			await get_tree().create_timer(0.5).timeout
			player.play(Anim.CLOSE)
			await player.animation_finished
			test_open = false

var player: AnimationPlayer:
	get: return _get_player()

var ref_rect: ReferenceRect:
	get: return _get_ref_rect()


func _ready() -> void:
	_get_player()
	_get_ref_rect()
	player.play(Anim.RESET)
	


func _get_player() -> AnimationPlayer:
	var node = get_node_or_null(PLAYER_NODE)
	if not node:
		node = _create_player()
	return node


func _get_ref_rect() -> ReferenceRect:
	var node = get_node_or_null(REF_RECT_NODE)
	if not node:
		node = _create_ref_rect()
	return node


func _create_player() -> AnimationPlayer:
	var new_player := AnimationPlayer.new()
	add_child(new_player)
	new_player.add_animation_library(ANIM_LIB_NAME, ANIMS)
	new_player.name = PLAYER_NODE
	return new_player


func _create_ref_rect() -> ReferenceRect:
	var new_rect := ReferenceRect.new()
	add_child(new_rect)
	new_rect.visible = show_reference_rect
	new_rect.name = REF_RECT_NODE
	new_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	new_rect.border_width = 3
	new_rect.mouse_filter = MOUSE_FILTER_IGNORE
	return new_rect


func open() -> void:
	if player:
		opened.emit()
		player.play(Anim.OPEN, -1, 1.5)
		await player.animation_finished
		is_open.emit()


func close() -> void:
	if player:
		closed.emit()
		player.play(Anim.CLOSE, -1, 1.5)
		await player.animation_finished
		is_closed.emit()
