class_name PanelButtonGroup
extends Container
@icon("panel_button_group.svg")

enum Flow {
	HORIZONTAL,
	VERTICAL
}

@export var flow: Flow = Flow.HORIZONTAL

var buttons: Array[PanelButton] = []
var container_base: Container:
	get: 
		var base: Container
		match flow:
			Flow.HORIZONTAL: base = HFlowContainer.new()
			_: base = VFlowContainer.new()
		
		base.visible = false
#		base.size_flags_horizontal = SIZE_EXPAND_FILL
#		base.size_flags_vertical = SIZE_EXPAND_FILL
		return base

@onready var left_container := container_base
@onready var right_container := container_base
@onready var containers = [left_container, right_container]


func _ready() -> void:
	Utils.add_child_at(self, left_container, 0)
	Utils.add_child_at(self, right_container, get_child_count())
	
	var i := 0
	for child in get_children():
		if child is PanelButton: 
			buttons.append(child)
			child.panel_disabled = true
			child.opening.connect(_on_button_opening.bind(child))
			child.closing.connect(
				func():
					await get_tree().create_timer(0.2525).timeout
					unsort_children()
			)
		
		child.set_meta("index", i)
		i += 1


func _on_button_opening(button: PanelButton) -> void:
	await close_other_buttons(button)
	resort_children(button)
	button._continue_open()


func close_other_buttons(exclude: PanelButton) -> void:
	var closing := false
	for button in buttons:
		if button.button_pressed and button != exclude:
			closing = true
			button.close()
	if closing: await get_tree().create_timer(0.25).timeout
	unsort_children()


func resort_children(button: PanelButton) -> void:
	unsort_children()
	var button_index: int = button.get_meta("index")
	
	for child in get_children():
		if child in containers: continue
		
		var i: int = child.get_meta("index")
		
		if i < button_index:
			Utils.transfer_child(self, left_container, child)
		
		elif i > button_index:
			Utils.transfer_child(self, right_container, child)
	
	for container in containers:
		if container.get_child_count() > 0: container.visible = true


func unsort_children() -> void:
	for child in left_container.get_children():
		Utils.transfer_child(left_container, self, child)
	
	for child in right_container.get_children():
		Utils.transfer_child(right_container, self, child)
	
	for child in get_children():
		move_child(child, child.get_meta("index"))
	
	left_container.reset_size()
	right_container.reset_size()
	
	left_container.visible = false
	right_container.visible = false
