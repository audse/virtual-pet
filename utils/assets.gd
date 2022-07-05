extends Node

const shaders = {
	distort = "",
	guide_distort = "res://apps/map/assets/shaders/distort_guide.gdshader"
}

const materials = {
	building_guide = "res://apps/map/assets/materials/building_guide.material"
}

var _cached_resources := {}


func import(path: String) -> Resource:
	var resource: Resource
	if path in _cached_resources: return _cached_resources[path]
	else:
		resource = load(path)
		_cached_resources[path] = resource
	return resource
