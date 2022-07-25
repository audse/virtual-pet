extends Node


var Random = RandomNumberGenerator.new()

func _ready() -> void:
	Random.randomize()
