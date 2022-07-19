extends Control

const PaintingScene: PackedScene = preload("res://apps/painter/painter.tscn")
const BuildingScene: PackedScene = preload("res://main.tscn")


func _on_painting_button_pressed() -> void:
	get_tree().change_scene_to(PaintingScene)


func _on_building_button_pressed() -> void:
	get_tree().change_scene_to(BuildingScene)
