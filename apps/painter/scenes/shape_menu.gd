extends PanelButton


func _ready() -> void:
	States.Paint.shape_changed.connect(
		func (s: int): 
			%CurrentShape.shape = s
			%CurrentShape.reload = true
	)
	super._ready()
