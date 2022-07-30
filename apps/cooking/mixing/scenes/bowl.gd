extends StaticBody3D

@onready var fill := $Fill as MeshInstance3D
@onready var fill_shader: ShaderMaterial = fill.get_surface_override_material(0) if fill else null
@onready var fill_vortex_shader: ShaderMaterial = fill_shader.next_pass if fill_shader else null
@onready var res := get_viewport().get_visible_rect().size
@onready var center := res / 2.0


func _ready() -> void:
	if fill_shader:
		fill_shader.set_shader_param("resolution", res * Vector2(0.5, 0.5))
	if fill_vortex_shader:
		fill_vortex_shader.set_shader_param("resolution", res * Vector2(0.5, 0.5))


var _vortex_strength: float = fill_vortex_shader.get_shader_param("vortex_direction") if fill_vortex_shader else 0.0:
	set(value):
		_vortex_strength = clamp(value, -30.0, 30.0)
		if fill_vortex_shader:
			fill_vortex_shader.set_shader_param("vortex_direction", _vortex_strength)


var _wave_intensity: float = fill_shader.get_shader_param("intensity") if fill_shader else 0.55:
	set(value):
		_wave_intensity = clamp(value, 0.35, 0.75)
		if fill_shader:
			fill_shader.set_shader_param("intensity", _wave_intensity)


var _prev_mouse_pos: Vector2
var _speed_delta: Vector2

func _process(_delta: float) -> void:
	if fill_shader:
		if abs(_vortex_strength) > 0.0: _vortex_strength = lerp(_vortex_strength, 0.0, 0.0005)
		if _wave_intensity > 0.25: _wave_intensity -= 0.001


func _get_fill_mouse_pos(mouse_pos: Vector2) -> Vector2:
	return (mouse_pos * Vector2(0.5, 0.5) - (res * 0.125) - Vector2(50, -30)).clamp(Vector2.ZERO, res / 2)


func _input(_event: InputEvent) -> void:
	if fill_shader: 
		var mouse_pos := get_viewport().get_mouse_position()
		if mouse_pos > res * Vector2(0.25, 0.15) and mouse_pos < res * Vector2(0.75, 0.85):
			_speed_delta = mouse_pos - _prev_mouse_pos
			
			var is_clockwise: bool = Vector2Ref.is_moving_clockwise(center, _prev_mouse_pos, mouse_pos)
			
			var stir_speed := _speed_delta.abs() / res
			
			_prev_mouse_pos = mouse_pos
			
			fill_shader.set_shader_param("mouse_pos", _get_fill_mouse_pos(mouse_pos))
			_vortex_strength += (stir_speed.x + stir_speed.y) * 10.0 * (1.0 if is_clockwise else -1.0)
			
			_wave_intensity += (stir_speed.x + stir_speed.y) / 3.0
