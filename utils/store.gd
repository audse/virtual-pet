class_name Store
extends RefCounted

signal changed(prop: String, val)

var data: Dictionary


func _init(data_val: Dictionary):
	data = data_val


static func _for_nested(obj: Dictionary, path: Array[String], fun: Callable):
	if len(path) == 1:
		return fun.call(obj, path[0])
	return _for_nested(obj, path.slice(1), fun)


func get_data(property: String):
	var val = _for_nested(
		data, 
		property.split("/"), 
		func (obj, prop):
			return obj[prop]
	)
	return val


func set_data(property: String, value):
	var val = _for_nested(
		data,
		property.split("/"),
		func (obj, prop):
			obj[prop] = value
			return value
	)
	changed.emit(property, val)
	return val


func push(property: String, value):
	var val = _for_nested(
		data,
		property.split("/"),
		func (obj, prop: String):
			if obj[prop] is Array:
				obj[prop].append(value)
			return obj[prop]
	)
	changed.emit(property, val)
	return val


func pop(property: String, back := true):
	var val = _for_nested(
		data,
		property.split("/"),
		func (obj, prop: String):
			if obj[prop] is Array:
				if back: obj[prop].pop_back()
				else: obj[prop].pop_front()
			return obj[prop]
	)
	changed.emit(property, val)
	return val


func subscribe(property: String, fun: Callable, once = false):
	changed.connect(
		func (prop: String, value):
			if prop == property:
				fun.call(prop, value),
		CONNECT_ONESHOT if once else 0
	)
