class_name Choppable
extends CSGCombiner3D
@icon("choppable.svg")

@onready var slices: Array = get_children()

var _current := 0


func chop() -> void:
	if _current < len(slices):
		for i in range(0, _current + 1):
			var slice: ChopSlice = slices[i]
			if slice and slice is ChopSlice: slice.chop()
		
		var curr: ChopSlice = slices[_current]
		if curr and curr is ChopSlice: curr.bounce()
		
		_current += 1
