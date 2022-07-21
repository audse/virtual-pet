class_name AnimBuilderResource
extends Resource

@export_group("Setup")

@export var setup_prop_names: Array[String]
@export var setup_prop_values: Array


@export_group("Keyframes")
@export var keyframes: Array[String]
@export var durations: Array[float]
@export var ease_types: Array[Tween.EaseType]
@export var trans_types: Array[Tween.TransitionType]


@export_group("Animation")

@export var anim_prop_names: Array[String]
@export var anim_prop_values: Array


@export_group("Tear down")

@export var tear_down_prop_names: Array[String]
@export var tear_down_prop_values: Array
