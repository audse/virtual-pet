extends Control

const WorldScene := preload("res://apps/world/world.tscn")
const DrawScene := preload("res://apps/painter/painter.tscn")
const PetColorScene := preload("res://apps/pet_color_maker/scenes/pet_color_maker.tscn")
const WriteGoalScene := preload("res://apps/goal/scenes/goal_editor.tscn")

@onready var button_back := %BackButton as Button
@onready var button_draw := %DrawButton as Button
@onready var button_pet_color := %MakePetColorButton as Button
@onready var button_write_goal := %WriteGoalButton as Button


@onready var scenes := {
	button_back: WorldScene,
	button_draw: DrawScene,
	button_pet_color: PetColorScene,
	button_write_goal: WriteGoalScene
}


func _ready():
	var tree := get_tree()
	for button in scenes.keys():
		button.pressed.connect(tree.change_scene_to_packed.bind(scenes[button]))
