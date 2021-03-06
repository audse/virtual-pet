extends PanelButton

const Size = States.PaintState.Size


func _ready() -> void:
	States.Paint.size_changed.connect(_on_size_changed)
	States.Paint.shape_changed.connect(
		func (s: int): 
			%CurrentShape.shape = s
			%CurrentShape.reload = true
	)
	super._ready()


func _on_increase_size_button_pressed() -> void:
	States.Paint.size += 1


func _on_decrease_size_button_pressed() -> void:
	States.Paint.size -= 1


func _on_size_changed(new_size: int) -> void:
	%IncreaseSizeButton.disabled = new_size >= Size.XXL
	%DecreaseSizeButton.disabled = new_size <= Size.XS


func _on_rotate_button_pressed(delta: float) -> void:
	States.Paint.rotation += int(delta)
