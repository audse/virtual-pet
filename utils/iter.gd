class_name Iter
extends RefCounted

var arr: Array
var i := 0
var cycle: bool
var cycles_completed: int = 0

func _init(val: Array, cycle_val: bool = false) -> void:
	arr = val
	cycle = cycle_val


static func of_len(num: int) -> Iter:
	return Iter.new(range(num))


func array() -> Array:
	return arr


func next():
	i += 1
	if len(arr) > i:
		return arr[i]
	if cycle:
		i = 0
		cycles_completed += 1
		return arr[i]


func prev():
	i -= 1
	if len(arr) > 0:
		return arr[i]
	if cycle:
		i = len(arr) - 1
		return arr[i]


func peek(amt: int, peek_cycle: bool = true):
	var j := i + amt
	if j >= 0 and j < len(arr):
		return arr[j]
	elif peek_cycle:
		if j >= len(arr): return arr[j - len(arr)]
		elif j < 0: return arr[len(arr) + j]


func for_each(fun: Callable) -> Iter:
	while i < len(arr):
		fun.call(arr[i], i, self)
		i += 1
	return self


func map(fun: Callable) -> Iter:
	var new_arr := []
	while i < len(arr):
		new_arr.append(fun.call(arr[i]))
		i += 1
	return Iter.new(new_arr)

func map_i(fun: Callable) -> Iter:
	var new_arr := []
	while i < len(arr):
		new_arr.append(fun.call(arr[i], i))
		i += 1
	return Iter.new(new_arr)

func sort(fun: Callable) -> Iter:
	arr.sort_custom(fun)
	return self

