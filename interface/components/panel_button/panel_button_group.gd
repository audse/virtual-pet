class_name PanelButtonGroup
extends Container
@icon("panel_button_group.svg")

enum Flow {
	HORIZONTAL,
	VERTICAL
}

@export var flow: Flow = Flow.HORIZONTAL

@onready var left_container: Container = HFlowContainer.new() if flow == Flow.HORIZONTAL else VFlowContainer.new()
@onready var right_container: Container = HFlowContainer.new() if flow == Flow.HORIZONTAL else VFlowContainer.new()
@onready var containers := [left_container, right_container]

var buttons: Array[PanelButton] = []


func _ready() -> void:
	Utils.add_child_at(self, left_container, 0)
	Utils.add_child_at(self, right_container, get_child_count())
	
	var i := 0
	for child in get_children():
		if child is PanelButton: 
			buttons.append(child)
			child.panel_disabled = true
			child.pressed.connect(_on_button_pressed.bind(child))
		child.set_meta("index", i)
		i += 1
	
	for container in containers:
		container.visible = false
		container.size_flags_horizontal = SIZE_EXPAND_FILL
		container.size_flags_vertical = SIZE_EXPAND_FILL


func _on_button_pressed(button: PanelButton) -> void:
	button.panel_disabled = false
	if button.button_pressed:
		await close_other_buttons(button)
		unsort_children()
		resort_children(button)
		button.open()
	else:
		button.close()
		await get_tree().create_timer(0.25).timeout
		unsort_children()
	button.panel_disabled = true


func close_other_buttons(exclude: PanelButton) -> void:
	var closing := false
	for button in buttons:
		if button.button_pressed and button != exclude:
			button.panel_disabled = false
			closing = true
			button.close()
			button.panel_disabled = true
	if closing: await get_tree().create_timer(0.25).timeout


func resort_children(button: PanelButton) -> void:
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
		print(container.get_child_count())


func unsort_children() -> void:
	for child in left_container.get_children():
		Utils.transfer_child(left_container, self, child)
	
	for child in right_container.get_children():
		Utils.transfer_child(right_container, self, child)
	
	for child in get_children():
		move_child(child, child.get_meta("index"))
	
	left_container.visible = false
	right_container.visible = false
