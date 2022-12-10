extends Node3D

@onready var main_light := %MainLight as DirectionalLight3D
@onready var soft_light := %SoftLight as DirectionalLight3D

const ROTATION_MIDNIGHT_START := deg_to_rad(90.0)
const ROTATION_MIDNIGHT_END := deg_to_rad(-270.0)

const SOFT_LIGHT_ROTATION_OFFSET := deg_to_rad(15.0)


func _ready():
	update_lights()
	Datetime.data.time_changed.connect(
		func(_time) -> void: update_lights()
	)


func update_lights() -> void:
	var percent: float = ease(Datetime.data.day_completeness, -1.2)
	
	main_light.rotation.x = lerp(ROTATION_MIDNIGHT_START, ROTATION_MIDNIGHT_END, percent)
	
	if percent < 0.5:
		for light in [main_light, soft_light]:
			light.light_energy = lerp(0.0, 1.0, percent * 2.0)
			light.light_indirect_energy = lerp(0.0, 1.0, percent * 2.0)
	else:
		for light in [main_light, soft_light]:
			light.light_energy = lerp(1.0, 0.0, (percent - 0.5) * 2.0)
			light.light_indirect_energy = lerp(1.0, 0.0, (percent - 0.5) * 2.0)
