@tool
class_name CircleMenu
extends CircleContainer

signal opening
signal open_complete
signal closing
signal close_complete

enum Origin { 
	TOP_LEFT, 
	TOP_CENTER, 
	TOP_RIGHT, 
	CENTER_LEFT, 
	CENTER, 
	CENTER_RIGHT, 
	BOTTOM_LEFT, 
	BOTTOM_CENTER,
	BOTTOM_RIGHT 
}

enum {
	BEFORE_OPEN, 
	DURING_OPEN, 
	AFTER_OPEN 
}

const MENU_BUTTON_PATH := NodePath("CircleMenuButton")
const CLOSE_BUTTON_PATH := NodePath("CircleCloseButton")
const MENU_BACKDROP_PATH := NodePath("CircleMenuBackdrop")
const MENU_BACKDROP_BLUR_PATH := NodePath("CircleMenuBackdrop/BlurRect")
const MENU_BACKDROP_BUFFER_PATH := NodePath("CircleMenuBackdrop/BackBufferCopy")
const CHILD_NODES: Array[NodePath] = [MENU_BUTTON_PATH, MENU_BACKDROP_PATH, CLOSE_BUTTON_PATH]
const DELAY := 0.1

const DEGREE_OF_ORIGIN := {
	Origin.TOP_LEFT     : 230.0,
	Origin.TOP_CENTER   : 260.0,
	Origin.TOP_RIGHT    : 300.0,
	Origin.CENTER_LEFT  : 190.0,
	Origin.CENTER       : 0.0,
	Origin.CENTER_RIGHT : 350.0,
	Origin.BOTTOM_LEFT  : 160.0,
	Origin.BOTTOM_CENTER: 100.0,
	Origin.BOTTOM_RIGHT : 40.0
}

func _offset_at_origin() -> float:
	var deg: float = DEGREE_OF_ORIGIN[origin]
	match origin:
		Origin.TOP_LEFT, Origin.TOP_RIGHT: deg -= 30
		Origin.TOP_CENTER, Origin.CENTER_RIGHT: deg -= 40
		Origin.BOTTOM_RIGHT: deg -= 50
		Origin.CENTER_LEFT, Origin.BOTTOM_CENTER: deg -= 60
		Origin.BOTTOM_LEFT: deg -= 80
		Origin.CENTER: deg += 40
		_: deg -= 20
	return deg

@export var origin: Origin = Origin.BOTTOM_LEFT:
	set(value):
		origin = value
		_reset()

@export var menu_open_icon: Texture:
	set(value):
		menu_open_icon = value
		menu_button.icon = value

@export var menu_close_icon: Texture:
	set(value):
		menu_close_icon = value
		close_button.icon = value

@export var menu_button_min_size: Vector2:
	set(value):
		menu_button_min_size = value
		menu_button.custom_minimum_size = value
		menu_button.size = value

@export var close_button_min_size: Vector2:
	set(value):
		close_button_min_size = value
		close_button.custom_minimum_size = value
		close_button.size = value

@export var menu_stylebox_override: StyleBox:
	set(value):
		menu_stylebox_override = value
		menu_backdrop.add_theme_stylebox_override("panel", value)

@export var override_degree_offset: float = -1.0:
	set(value):
		override_degree_offset = value
		_reset()

@export var use_blur: bool = true:
	set(value):
		use_blur = value
		menu_backdrop_blur.material.set_shader_parameter("blur_amount", 3.0 if use_blur else 0.0)
		_reset()

@export var test_open: bool = false:
	set(_value): open()

@export var test_close: bool = false:
	set(_value): close()

@export var is_open: bool = false:
	set(value):
		is_open = value
		if is_open: _state = AFTER_OPEN
		else: _state = BEFORE_OPEN
		_reset()

@export var remake: bool = false:
	set(_value):
		_remake_menu_button()
		_remake_close_button()
		_remake_backdrop()
		_remake_backdrop_blur()
		_remake_backdrop_buffer()
		_reset()

var _state := BEFORE_OPEN

var menu_button: Button:
	get: 
		var node: Button = get_node_or_null(MENU_BUTTON_PATH)
		if not node: node = _remake_menu_button()
		return node


func _remake_menu_button() -> Button:
	var node: Button = get_node_or_null(MENU_BUTTON_PATH)
	if node: remove_child(node)
	node = Button.new()
	node.icon = menu_open_icon
	node.name = MENU_BUTTON_PATH.get_name(0)
	add_child(node)
	node.pressed.connect(_on_menu_button_pressed)
	node.theme_type_variation = "CircleMenuButton"
	node.expand_icon = true
	node.custom_minimum_size = menu_button_min_size
	node.size = menu_button_min_size
	node.move_to_front()
	return node


var close_button: Button:
	get: 
		var node: Button = get_node_or_null(CLOSE_BUTTON_PATH)
		if not node: node = _remake_close_button()
		return node


func _remake_close_button() -> Button:
	var node: Button = get_node_or_null(CLOSE_BUTTON_PATH)
	if node: remove_child(node)
	node = Button.new()
	node.icon = menu_close_icon
	node.name = CLOSE_BUTTON_PATH.get_name(0)
	add_child(node)
	node.pressed.connect(_on_close_button_pressed)
	node.theme_type_variation = "CircleMenuCloseButton"
	node.expand_icon = true
	node.custom_minimum_size = close_button_min_size
	node.size = close_button_min_size
	node.move_to_front()
	return node


var menu_backdrop: PanelContainer:
	get: 
		var node: PanelContainer = get_node_or_null(MENU_BACKDROP_PATH)
		if not node: node = _remake_backdrop()
		return node


func _remake_backdrop() -> PanelContainer:
	var node: PanelContainer = get_node_or_null(MENU_BACKDROP_PATH)
	if node: remove_child(node)
	node = PanelContainer.new()
	if menu_stylebox_override:
		node.add_theme_stylebox_override("panel", menu_stylebox_override)
	node.name = MENU_BACKDROP_PATH.get_name(0)
	node.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(node)
	move_child(node, 0)
	return node


var menu_backdrop_blur: ColorRect:
	get: 
		var node: ColorRect = get_node_or_null(MENU_BACKDROP_BLUR_PATH)
		if not node: node = _remake_backdrop_blur()
		return node


func _remake_backdrop_blur() -> ColorRect:
	var node: ColorRect = get_node_or_null(MENU_BACKDROP_BLUR_PATH)
	if node: menu_backdrop.remove_child(node)
	node = ColorRect.new()
	node.name = MENU_BACKDROP_BLUR_PATH.get_name(1)
	menu_backdrop.add_child(node)
	node.material = ShaderMaterial.new()
	node.material.shader = load("res://apps/painter/assets/shaders/rounded_blur.gdshader")
	node.material.set_shader_parameter("blur_amount", 3.0 if use_blur else 0.0)
	node.material.set_shader_parameter("radius", 1.0)
	node.show_behind_parent = true
	return node


var menu_backdrop_buffer: BackBufferCopy:
	get: 
		var node: BackBufferCopy = get_node_or_null(MENU_BACKDROP_BUFFER_PATH)
		if not node: node = _remake_backdrop_buffer()
		return node


func _remake_backdrop_buffer() -> BackBufferCopy:
	var node: BackBufferCopy = get_node_or_null(MENU_BACKDROP_BUFFER_PATH)
	if node: menu_backdrop.remove_child(node)
	node = BackBufferCopy.new()
	node.rect = Rect2(Vector2.ZERO, menu_size)
	node.name = MENU_BACKDROP_BUFFER_PATH.get_name(1)
	menu_backdrop.add_child(node)
	return node


func _get_factor_from_origin() -> Vector2:
	var factor := Vector2.ZERO
	match origin:
		Origin.TOP_LEFT     : pass
		Origin.TOP_CENTER   : factor.x = 0.5
		Origin.TOP_RIGHT    : factor.x = 1.0
		Origin.CENTER_LEFT  : factor.y = 0.5
		Origin.CENTER       : factor = Vector2(0.5, 0.5)
		Origin.CENTER_RIGHT : factor = Vector2(1.0, 0.5)
		Origin.BOTTOM_LEFT  : factor.y = 1.0
		Origin.BOTTOM_CENTER: factor = Vector2(0.5, 1.0)
		Origin.BOTTOM_RIGHT : factor = Vector2.ONE
	return factor


var _menu_origin_pos: Vector2:
	get: return menu_pos + (menu_size * _get_factor_from_origin())

var menu_size: Vector2:
	get: 
		if size.x < size.y: return Vector2(size.x, size.x)
		else: return Vector2(size.y, size.y)

var menu_pos: Vector2:
	get:
		var msize := menu_size
		var pos := (size - msize) / 2
		if size.x < size.y: return Vector2(0, pos.y)
		else: return Vector2(pos.x, 0)


func _reset_self() -> void:
	match _state:
		BEFORE_OPEN:
			_temp_degree_range = 0.0
			_temp_degree_offset = _get_degree_offset() - 20.0
			_temp_extra_margin = radius
		AFTER_OPEN:
			degree_offset = _get_degree_offset()
			_temp_degree_range = degree_range
			_temp_extra_margin = extra_margin


var _menu_button_radius: float:
	get: return min(size.x, size.y) / 6 - extra_margin


func _reset_menu_button_pos(button: Button) -> void:
	if origin != Origin.CENTER:
		button.position = _to_circle_pos(center, _menu_button_radius, DEGREE_OF_ORIGIN[origin]) 
	else: 
		button.position = _get_node_origin_pos(_menu_origin_pos, button, true)


func _reset_menu_button() -> void:
	_reset_menu_button_pos(menu_button)
	match _state:
		BEFORE_OPEN: menu_button.visible = true
		AFTER_OPEN: menu_button.visible = false
	menu_button.move_to_front()


func _reset_close_button() -> void:
	_reset_menu_button_pos(close_button)
	match _state:
		BEFORE_OPEN: close_button.visible = false
		AFTER_OPEN: close_button.visible = true
	close_button.move_to_front()


func _get_backdrop_pivot() -> Vector2:
	var offset := Vector2.ZERO
	if size.y > size.x and abs(size.y - size.x) > 10.0: offset.y = -menu_size.y
	elif size.x > size.y and abs(size.x - size.y) > 10.0: offset.x = -menu_size.x
	return menu_button.position + (offset / 2) + (menu_button.size * _get_factor_from_origin())


func _reset_backdrop() -> void:
	menu_backdrop.size = menu_size
	menu_backdrop.position = menu_pos
	menu_backdrop.pivot_offset = _get_backdrop_pivot()
	menu_backdrop.scale = Vector2.ONE
	match _state:
		BEFORE_OPEN: menu_backdrop.visible = false
		AFTER_OPEN: menu_backdrop.visible = true


func _reset_backdrop_buffer() -> void:
	menu_backdrop_buffer.rect = Rect2(Vector2.ZERO, menu_size)


func _reset_backdrop_blur() -> void:
	menu_backdrop_blur.position = Vector2.ZERO
	menu_backdrop_blur.size = menu_size


func _reset_items() -> void:
	_for_each_child(
		func(item: Node, _i: int) -> void:
			item.scale = Vector2.ONE
			item.rotation = 0
			match _state:
				BEFORE_OPEN: item.visible = false
				AFTER_OPEN: item.visible = true
	)


func _for_each_child(do_something: Callable) -> void:
	var index: int = 0
	for item in get_children():
		if not get_path_to(item) in CHILD_NODES:
			do_something.call(item, index)
			index += 1


func _ready() -> void:
	_reset()

var _is_animating: bool = false


func queue_open() -> void:
	if _state == BEFORE_OPEN and _is_animating:
		close_complete.connect(open, CONNECT_ONE_SHOT)
	elif not _is_animating: open()


func queue_close() -> void:
	if _state == AFTER_OPEN and _is_animating:
		open_complete.connect(close, CONNECT_ONE_SHOT)
	elif not _is_animating: close()


func open() -> void:
	_is_animating = true
	opening.emit()
	_reset()
	
	_tween_self()
	_tween_backdrop()
	_tween_menu_buttons()
	
	_for_each_child(
		func(item: Node, index: int) -> void:
			await get_tree().create_timer(DELAY * index).timeout
			Anim.pop_spin_toggle(item, -1)
	)
	
	await get_tree().create_timer(1.0).timeout
	_is_animating = false
	is_open = true


func close() -> void:
	_is_animating = true
	closing.emit()
	_reset()
	
	_tween_self()
	_tween_backdrop()
	_tween_menu_buttons()
	
	_for_each_child(
		func(item: Node, index: int) -> void:
			await get_tree().create_timer(DELAY * index).timeout
			Anim.pop_spin_toggle(item, -1)
	)
	
	await get_tree().create_timer(0.75).timeout
	_is_animating = false
	is_open = false


func _on_menu_button_pressed() -> void: 
	if not is_open: queue_open()


func _on_close_button_pressed() -> void:
	if is_open: queue_close()


func _tween_self() -> void:
	match _state:
		BEFORE_OPEN: await (
			AnimBuilder
				.new(self)
				.keyframe("enter", 0.75)
				.props({
					_temp_degree_range  = { enter = degree_range  },
					_temp_degree_offset = { enter = degree_offset },
					_temp_extra_margin  = { enter = extra_margin  }
				})
				.complete()
		)
		AFTER_OPEN: 
			await get_tree().create_timer(0.25).timeout
			await (
				AnimBuilder
					.new(self)
					.keyframe("exit", 0.55)
					.props({
						_temp_degree_range  = { exit = 0.0 },
						_temp_degree_offset = { exit = _get_degree_offset() - 20.0 },
						_temp_extra_margin  = { exit = radius }
					})
					.complete()
			)


func _tween_backdrop() -> void:
	match _state:
		BEFORE_OPEN: 
			await (
				AnimBuilder
					.new(menu_backdrop)
					.setup({
						scale   = Vector2.ZERO,
						visible = true,
					})
					.keyframe("enter", 0.25, Tween.EASE_OUT)
					.keyframe("settle", 0.35)
					.prop("scale", {
						enter  = Vector2(1.1, 1.1),
						settle = Vector2.ONE,
					})
					.complete()
			)
		AFTER_OPEN:
			await get_tree().create_timer(0.15).timeout
			await (
				AnimBuilder
					.new(menu_backdrop)
					.keyframe("anticipation", 0.25, Tween.EASE_OUT)
					.keyframe("exit", 0.15)
					.prop("scale", {
						anticipation  = Vector2(1.1, 1.1),
						exit = Vector2.ZERO,
					})
					.complete()
			)


func _tween_menu_buttons() -> void:
	menu_button.disabled = true
	close_button.disabled = true
	match _state:
		BEFORE_OPEN:
			await Anim.pop_exit(menu_button)
			await Anim.pop_enter(close_button)
		AFTER_OPEN:
			await Anim.pop_exit(close_button)
			await Anim.pop_enter(menu_button)
	menu_button.disabled = false
	close_button.disabled = false


func _sort_children() -> void:
	for node_path in CHILD_NODES:
		if node_path not in unsorted:
			unsorted.append(node_path)
	super._sort_children()


func _reset() -> void:
	_reset_self()
	_reset_backdrop()
	_reset_backdrop_buffer()
	_reset_backdrop_blur()
	_reset_menu_button()
	_reset_close_button()
	_reset_items()
	
	_sort_children()


func _get_degree_offset() -> float:
	if override_degree_offset < 0.0:
		return (360 - degree_range) / 2 + _offset_at_origin()
	else: 
		return override_degree_offset


func _get_node_origin_pos(from: Vector2, node: Control, with_margin: bool = false) -> Vector2:
	var m := Vector2(extra_margin, extra_margin) if with_margin else Vector2.ZERO
	var pos := from - (node.size * _get_factor_from_origin())
	
	if node:
		match origin:
			Origin.TOP_LEFT: pos += m
			Origin.TOP_CENTER: pos.y += m.y
			Origin.TOP_RIGHT: pos += Vector2(-m.x, m.y)
			Origin.CENTER_LEFT: pos.x += m.x
			Origin.CENTER: pass
			Origin.CENTER_RIGHT: pos.x -= m.x
			Origin.BOTTOM_LEFT: pos += Vector2(m.x, -m.y)
			Origin.BOTTOM_CENTER: pos.y -= m.y
			Origin.BOTTOM_RIGHT: from -= m
	return from
