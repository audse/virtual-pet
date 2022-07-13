@tool
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
const DELAY := 0.05

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
		_menu_button.icon = value

@export var menu_close_icon: Texture:
	set(value):
		menu_close_icon = value
		_close_button.icon = value

@export var menu_button_min_size: Vector2:
	set(value):
		menu_button_min_size = value
		_menu_button.custom_minimum_size = value
		_menu_button.size = value

@export var close_button_min_size: Vector2:
	set(value):
		close_button_min_size = value
		_close_button.custom_minimum_size = value
		_close_button.size = value

@export var menu_stylebox_override: StyleBox:
	set(value):
		menu_stylebox_override = value
		_menu_backdrop.add_theme_stylebox_override("panel", value)

@export var override_degree_offset: float = -1.0:
	set(value):
		override_degree_offset = value
		_reset()

@export var use_blur: bool = true:
	set(value):
		use_blur = value
		if not use_blur and _menu_backdrop_blur:
			_menu_backdrop_blur.set_shader_param("blur_amount", 0.0)
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
var _final_state: int:
	get: 
		if _state == BEFORE_OPEN: return AFTER_OPEN
		else: return BEFORE_OPEN
var _ease: int:
	get: 
		if _state == BEFORE_OPEN: return Tween.EASE_OUT
		else: return Tween.EASE_IN

var _menu_button: Button:
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
	return node


var _close_button: Button:
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
	node.custom_minimum_size = menu_button_min_size
	return node


var _menu_backdrop: PanelContainer:
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


var _menu_backdrop_blur: ColorRect:
	get: 
		var node: ColorRect = get_node_or_null(MENU_BACKDROP_BLUR_PATH)
		if not node: node = _remake_backdrop_blur()
		return node


func _remake_backdrop_blur() -> ColorRect:
	var node: ColorRect = get_node_or_null(MENU_BACKDROP_BLUR_PATH)
	if node: _menu_backdrop.remove_child(node)
	node = ColorRect.new()
	node.name = MENU_BACKDROP_BLUR_PATH.get_name(1)
	_menu_backdrop.add_child(node)
	node.material = ShaderMaterial.new()
	node.material.shader = load("res://apps/painter/assets/shaders/rounded_blur.gdshader")
	node.material.set_shader_param("blur_amount", 3.0 if use_blur else 0.0)
	node.material.set_shader_param("radius", 1.0)
	node.show_behind_parent = true
	return node


var _menu_backdrop_buffer: BackBufferCopy:
	get: 
		var node: BackBufferCopy = get_node_or_null(MENU_BACKDROP_BUFFER_PATH)
		if not node: node = _remake_backdrop_buffer()
		return node


func _remake_backdrop_buffer() -> BackBufferCopy:
	var node: BackBufferCopy = get_node_or_null(MENU_BACKDROP_BUFFER_PATH)
	if node: _menu_backdrop.remove_child(node)
	node = BackBufferCopy.new()
	node.rect = Rect2(Vector2.ZERO, menu_size)
	node.name = MENU_BACKDROP_BUFFER_PATH.get_name(1)
	_menu_backdrop.add_child(node)
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


func _self_props() -> Dictionary:
	return {
		"static": {
			"degree_range": degree_range,
			"degree_offset": _get_degree_offset(),
			"extra_margin": extra_margin,
		},
		"animated": {
			"_temp_degree_range": {
				BEFORE_OPEN: 0.0,
				AFTER_OPEN: degree_range,
			},
			"_temp_degree_offset": {
				BEFORE_OPEN: degree_offset - 20.0,
				AFTER_OPEN: degree_offset, 
			},
			"_temp_extra_margin": {
				BEFORE_OPEN: radius,
				AFTER_OPEN: extra_margin,
			}
		}
	}

var _menu_button_radius: float:
	get: return min(size.x, size.y) / 6 - extra_margin


func _menu_button_props() -> Dictionary:
	return {
			"static": {
				"text": "",
				"size": Vector2(0, 0),
				"position": func() -> Vector2:
					if origin != Origin.CENTER:
						return _to_circle_pos(center, _menu_button_radius, DEGREE_OF_ORIGIN[origin]) 
					else: return _get_node_origin_pos(_menu_origin_pos, _menu_button, true),
				"pivot_offset": _menu_button.size / 2
			},
			"animated": {
				"rotation": {
					BEFORE_OPEN: 0.0,
					DURING_OPEN: deg2rad(-10),
					AFTER_OPEN: deg2rad(180),
				},
				"scale": {
					BEFORE_OPEN: Vector2.ONE,
					DURING_OPEN: Vector2(1.1, 1.1),
					AFTER_OPEN: Vector2.ZERO
				}
			}
		}


func _close_button_props() -> Dictionary:
	return {
		"static": {
			"text": "",
			"size": Vector2(0, 0),
			"position": func() -> Vector2:
				if origin != Origin.CENTER:
					return _to_circle_pos(center, _menu_button_radius, DEGREE_OF_ORIGIN[origin]) 
				else: return _get_node_origin_pos(_menu_origin_pos, _close_button, true),
			"pivot_offset": _close_button.size / 2
		},
		"animated": {
			"rotation": {
				BEFORE_OPEN: deg2rad(-60),
				DURING_OPEN: deg2rad(-10),
				AFTER_OPEN: 0.0,
			},
			"scale": {
				BEFORE_OPEN: Vector2.ZERO,
				DURING_OPEN: Vector2(1.1, 1.1),
				AFTER_OPEN: Vector2.ONE
			}
		}
	}


func _menu_backdrop_props() -> Dictionary:
	return {
		"static": {
			"size": menu_size,
			"position": menu_pos,
			"pivot_offset": (func() -> Vector2: 
				var offset := Vector2.ZERO
				if size.y > size.x and abs(size.y - size.x) > 10.0: offset.y = -menu_size.y
				elif size.x > size.y and abs(size.x - size.y) > 10.0: offset.x = -menu_size.x
				return _menu_button.position + (offset / 2) + ((_menu_button.size / 2) * _get_factor_from_origin()))
		},
		"animated": {
			"scale": {
				BEFORE_OPEN: Vector2.ZERO,
				AFTER_OPEN: Vector2.ONE,
			},
		}
	}


func _menu_backdrop_buffer_props() -> Dictionary:
	return {
		"static": {
			"rect": Rect2(Vector2.ZERO, menu_size)
		},
		"animated": {}
	}

func _menu_backdrop_blur_props() -> Dictionary:
	return {
		"static": {
			"rect": Rect2(Vector2.ZERO, menu_size)
		},
		"animated": {}
	}


func _item_props(item: Control) -> Dictionary: 
	return {
		"static": { "pivot_offset": item.size / 2 },
		"animated": {
			"scale": { 
				BEFORE_OPEN: Vector2.ZERO,
				AFTER_OPEN: Vector2.ONE,
			},
			"rotation": { 
				BEFORE_OPEN: deg2rad(-180),
				AFTER_OPEN: 0.0,
			},
			"visible": {
				BEFORE_OPEN: false,
				AFTER_OPEN: true,
			}
		}
	}


func _node_props() -> Dictionary: 
	var list := {
		self: _self_props(),
		_menu_button: _menu_button_props(),
		_menu_backdrop: _menu_backdrop_props(),
		_close_button: _close_button_props(),
		_menu_backdrop_buffer: _menu_backdrop_buffer_props(),
		_menu_backdrop_blur: _menu_backdrop_blur_props()
	}
	_for_each_child(
		func(item: Node, _i: int) -> void:
			list[item] = _item_props(item)
	)
	return list


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
	if _is_animating:
		close_complete.connect(open)
	else: open()

func queue_close() -> void:
	if _is_animating:
		open_complete.connect(close)
	else: close()

func open() -> void:
	_is_animating = true
	_reset()
	
	_tween_container()
	_tween_backdrop()
	_tween_all_menu_buttons()
	
	_for_each_child(
		func(item: Node, index: int) -> void:
			await get_tree().create_timer(DELAY * index).timeout
			_tween_item(item)
	)
	
	await get_tree().create_timer(1.0).timeout
	_is_animating = false
	is_open = true


func close() -> void:
	_is_animating = true
	_reset()
	
	_tween_container()
	_tween_backdrop()
	_tween_all_menu_buttons()
	
	_for_each_child(
		func(item: Node, index: int) -> void:
			await get_tree().create_timer(DELAY * index).timeout
			_tween_item(item)
	)
	
	await get_tree().create_timer(0.75).timeout
	_is_animating = false
	is_open = false


func _on_menu_button_pressed() -> void: 
	if not is_open and not _is_animating:
		open()


func _on_close_button_pressed() -> void:
	if is_open and not _is_animating:
		close()


func _tween(ease_val: int) -> Tween:
	return (
		get_tree()
			.create_tween()
			.set_ease(ease_val)
			.set_trans(Tween.TRANS_CUBIC)
			.set_parallel()
		)


func _tween_container() -> void:
	var duration := 0.55 if _state == BEFORE_OPEN else 0.35
	var props: Dictionary = _self_props().animated
	var tween := _tween(_ease)
	for prop in props.keys():
		tween.tween_property(self, prop, props[prop][_final_state], duration)
	await tween.finished


func _tween_backdrop() -> void:
	if _state != BEFORE_OPEN: await get_tree().create_timer(0.15).timeout
	await _tween_props(
		_menu_backdrop, 
		_menu_backdrop_props().animated, 
		Tween.EASE_IN_OUT, 
		0.55 if _state == BEFORE_OPEN else 0.35
	)


func _tween_props(node: Control, props: Dictionary, ease_val: int = _ease, duration: float = 0.15) -> void:
	var tween := _tween(ease_val)
	for prop in props.keys():
		tween.tween_property(node, prop, props[prop][_final_state], duration)
	await tween.finished


func _tween_during_open(node: Control) -> void:
	var node_props = _node_props()
	if node in node_props:
		var props: Dictionary = node_props[node].animated
		var tween := _tween(Tween.EASE_IN_OUT)
		for prop in props.keys():
			if DURING_OPEN in props[prop]:
				tween.tween_property(node, prop, props[prop][DURING_OPEN], 0.15)
		await tween.finished


func _tween_menu_button() -> void:
	if _state == BEFORE_OPEN: await _tween_during_open(_menu_button)	
	await _tween_props(
		_menu_button,
		_menu_button_props().animated,
	)


func _tween_close_button() -> void:
	if _state == AFTER_OPEN: await _tween_during_open(_close_button)
	await _tween_props(
		_close_button,
		_close_button_props().animated,
	)


func _tween_all_menu_buttons() -> void:
	if _state == BEFORE_OPEN:
		_tween_menu_button()
		await get_tree().create_timer(0.25).timeout
		await _tween_close_button()
	else:
		_tween_close_button()
		await get_tree().create_timer(0.25).timeout
		await _tween_menu_button()


func _tween_item(item: Control) -> void:
	await Anim.pop_spin_toggle(item)
#	var duration := 0.35 if _state == BEFORE_OPEN else 0.15
#	var node_props := _node_props()
#	_tween_props(
#		item,
#		node_props[item].animated if item in node_props else {},
#		Tween.EASE_IN_OUT,
#		duration
#	)
#	await get_tree().create_timer(duration).timeout


func _sort_children() -> void:
	for node_path in CHILD_NODES:
		if node_path not in unsorted:
			unsorted.append(node_path)
	super._sort_children()


func _reset() -> void:
	var node_props := _node_props()
	for node in node_props.keys():
		var props = node_props[node]
		for prop in props["static"].keys():
			var val = props["static"][prop]
			if val is Callable:
				val = val.call()
			node.set(prop, val)
		
		for prop in props.animated.keys():
			node.set(prop, props.animated[prop][_state])
	_temp_degree_offset = degree_offset
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
