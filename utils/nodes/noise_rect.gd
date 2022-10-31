@tool
class_name GradientNoiseRect
extends ColorRect
@icon("noise_rect.svg")

## This creates a gradient of noise with a blend mode set to multiply.
## This reduces banding when applied on top of gradients.

enum Origin {
	TOP_LEFT,
	TOP,
	TOP_RIGHT,
	LEFT,
	RIGHT,
	BOTTOM_LEFT,
	BOTTOM,
	BOTTOM_RIGHT
}

const SHADER = preload("res://static/shaders/gradient_noise.gdshader")

@export var origin: Origin = Origin.TOP_LEFT:
	set(value):
		origin = value
		if material: 
			material.set_shader_parameter("origin", origin_point)
			material.set_shader_parameter("flip_x", flip_x)
			material.set_shader_parameter("flip_y", flip_y)
		else: make()

@export var weight := 0.0:
	set(value):
		weight = value
		if material: material.set_shader_parameter("weight", weight)
		else: make()

@export var alpha := 1.0:
	set(value):
		alpha = value
		if material: material.set_shader_parameter("alpha", alpha)
		else: make()

@export var reload: bool = false:
	set(_value): make()

var origin_point: Vector2:
	get: match origin:
			Origin.TOP_LEFT, Origin.TOP_RIGHT, Origin.BOTTOM_LEFT, Origin.BOTTOM_RIGHT: return Vector2(0.5, 0.5)
			Origin.TOP, Origin.BOTTOM: return Vector2(1, 0)
			Origin.LEFT, Origin.RIGHT, _: return Vector2(0, 1)

var flip_x: bool:
	get: match origin:
			Origin.TOP_RIGHT, Origin.BOTTOM_RIGHT, Origin.RIGHT: return true
			_: return false

var flip_y: bool:
	get: match origin:
			Origin.BOTTOM_LEFT, Origin.BOTTOM_RIGHT, Origin.BOTTOM: return true
			_: return false


var mat := ShaderMaterial.new()
var noise_tex := NoiseTexture2D.new()


func _ready() -> void:
	await RenderingServer.frame_post_draw
	make()


func make() -> void:
	make_noise()
	mat.shader = SHADER
	mat.set_shader_parameter("noise", noise_tex)
	material.set_shader_parameter("noise_size", size)
	material.set_shader_parameter("origin", origin_point)
	material.set_shader_parameter("flip_x", flip_x)
	material.set_shader_parameter("flip_y", flip_y)
	material.set_shader_parameter("weight", weight)
	material.set_shader_parameter("alpha", alpha)


func make_noise() -> void:
	var n := FastNoiseLite.new()
	n.frequency = 1.0
	noise_tex.width = max(1, int(size.x))
	noise_tex.height = max(1, int(size.y))
	noise_tex.noise = n
