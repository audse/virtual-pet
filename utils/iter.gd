class_name Iter
extends RefCounted

var arr: Array
var i := 0


func _init(val: Array) -> void:
	arr = val


func array() -> Array:
	return arr


func next():
	i += 1
	if len(arr) > i:
		return arr[i]


func for_each(fun: Callable) -> Iter:
	while i < len(arr):
		fun.call(arr[i], i)
		i += 1
	return self


func map(fun: Callable) -> Iter:
	var new_arr := []
	while i < len(arr):
		new_arr.append(fun.call(arr[i], i))
		i += 1
	return Iter.new(new_arr)


func sort(fun: Callable) -> Iter:
	arr.sort_custom(fun)
	return self

