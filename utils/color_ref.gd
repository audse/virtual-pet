class_name ColorRef
extends Object

var base: Color

const EMERALD_200 := Color("#a7f3d0")
const EMERALD_300 := Color("#6ee7b7")
const EMERALD_400 := Color("#34d399")

const SKY_200 := Color("#bae6fd")
const SKY_300 := Color("#7dd3fc")
const SKY_400 := Color("#38bdf8")

const INDIGO_200 := Color("#c7d2fe")
const INDIGO_300 := Color("#a5b4fc")
const INDIGO_400 := Color("#818cf8")

const FUCHSIA_200 := Color("#f5d0fe")
const FUCHSIA_300 := Color("#f0abfc")
const FUCHSIA_400 := Color("#e879f9")

func _init(value: Color) -> void:
	base = value


static func for_rgb(color: Color, fun: Callable) -> Color:
	for component in ["r", "g", "b"]:
		color[component] = fun.call(color[component], component)
	return color


static func for_rgba(color: Color, fun: Callable) -> Color:
	for component in ["r", "g", "b", "a"]:
		color[component] = fun.call(color[component], component)
	return color


static func lerp_rgba(a: Color, b: Color, weight := 1.0) -> Color:
	return Color(a.lerp(b, weight), lerp(a.a, b.a, weight))


static func min_of(colors: Array[Color]) -> Color:
	colors.sort_custom(
		func (a: Color, b: Color) -> bool: 
			return a.get_luminance() < b.get_luminance()
	)
	return colors[0]


static func max_of(colors: Array[Color]) -> Color:
	colors.sort_custom(
		func (a: Color, b: Color) -> bool: 
			return a.get_luminance() > b.get_luminance()
	)
	return colors[0]


static func multiply_component(a: float, b: float) -> float:
	return a * b


static func multiply(a: Color, b: Color, weight := 1.0) -> Color:
	return lerp_rgba(a, b, weight)


static func screen_component(a: float, b: float) -> float:
	return 1.0 - (1.0 - a) * (1.0 - b)


static func screen(a: Color, b: Color, weight := 1.0) -> Color:
	var color := for_rgba(
		a,
		func(val: float, component: String) -> float:
			return screen_component(val, b[component])
	)
	return lerp_rgba(a, color, weight)


static func add(a: Color, b: Color, weight := 1.0) -> Color:
	return a.lerp(a + b, weight)


static func subtract_component(a: float, b: float) -> float:
	return a + b - 1.0


static func subtract(a: Color, b: Color, weight := 1.0) -> Color:
	var color := for_rgba(
		a,
		func (val: float, component: String) -> float:
			return subtract_component(val, b[component])
	)
	return lerp_rgba(a, color, weight)


static func darken(a: Color, b: Color, weight := 1.0) -> Color:
	return a.lerp(min_of([a, b]), weight)


static func lighten(a: Color, b: Color, weight := 1.0) -> Color:
	return a.lerp(max_of([a, b]), weight)


static func burn_component(a: float, b: float) -> float:
	return 1.0 - ((1.0 - b) / a)


static func burn(a: Color, b: Color, weight := 1.0) -> Color:
	var color := for_rgba(
		a,
		func (val: float, component: String) -> float:
			return burn_component(val, b[component])
	)
	return a.lerp(color, weight)


static func dodge_component(a: float, b: float) -> float:
	return b / (1.0 - a)


static func dodge(a: Color, b: Color, weight := 1.0) -> Color:
	var color := for_rgba(
		a,
		func (val: float, component: String) -> float:
			return dodge_component(val, b[component])
	)
	return lerp_rgba(a, color, weight)


static func overlay_component(a: float, b: float) -> float:
	if a > 0.5:
		var unit := (1.0 - a) / 0.5
		var min_val := b - (1.0 - a)
		return b * unit + min_val
	else:
		var unit := a / 0.5
		return b * unit


static func overlay(a: Color, b: Color, weight := 1.0) -> Color:
	var color := for_rgba(
		a, 
		func (val: float, component: String) -> float:
			return overlay_component(val, b[component])
	)
	return lerp_rgba(a, color, weight)


static func soft_light_component(a: float, b: float) -> float:
	if b < 0.5: return (2.0 * a * b) + pow(a, 2.0) * (1.0 - 2.0 * b)
	else: return (2.0 * a * (1.0 - b)) + sqrt(a) * (2.0 * b - 1.0)


static func soft_light(a: Color, b: Color, weight := 1.0) -> Color:
	var color := for_rgba(
		a,
		func (val: float, component: String) -> float:
			return soft_light_component(val, b[component])
	)
	return lerp_rgba(a, color, weight)


static func hue(color: Color, shift: float) -> Color:
	color.h += shift
	return color


static func saturate(color: Color, shift: float) -> Color:
	color.s += shift
	return color


static func alpha(color: Color, shift: float) -> Color:
	color.a += shift
	return color


static func scale(a: Color, b: Color, inbetweens: int) -> Array[Color]:
	var colors := [a]
	var factor := 1.0 / (inbetweens + 1)
	for i in range(inbetweens):
		colors.append(lerp_rgba(a, b, factor * (i + 1)))
	colors.append(b)
	return colors


static func interpolate(colors: Array[Color], value: float) -> Color:
	var step := 1.0 / float(colors.size() - 1)
	var a: int = floori(value / step)
	var b: int = ceili(value / step)
	return ColorRef.lerp_rgba(colors[a], colors[b], value / step)


## Instance methods

func done() -> Color:
	return base


func and_multiply(b: Color, weight := 1.0) -> ColorRef:
	base = ColorRef.multiply(base, b, weight)
	return self


func and_screen(b: Color, weight := 1.0) -> ColorRef:
	base = ColorRef.screen(base, b, weight)
	return self

# TODO other methods


func and_hue(shift: float) -> ColorRef:
	base.h += shift
	return self


func and_saturate(shift: float) -> ColorRef:
	base.s += shift
	return self


func and_alpha(shift: float) -> ColorRef:
	base.a += shift
	return self
	
