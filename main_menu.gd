extends Control

const PaintingScene:  PackedScene = preload("res://apps/painter/painter.tscn")
const BuildingScene:  PackedScene = preload("res://apps/world/world.tscn")
const NormalMapScene: PackedScene = preload("res://apps/normal_map_maker/normal_map_maker.tscn")


func _on_painting_button_pressed() -> void:
	get_tree().change_scene_to_packed(PaintingScene)


func _on_building_button_pressed() -> void:
	get_tree().change_scene_to_packed(BuildingScene)


func _on_normal_map_button_pressed() -> void:
	get_tree().change_scene_to_packed(NormalMapScene)
