@tool
extends CircleContainer

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

const MENU_BUTTON_PATH := NodePath("CircleMenuButton")
const CLOSE_BUTTON_PATH := NodePath("CircleCloseButton")
const MENU_BACKDROP_PATH := NodePath("CircleMenuBackdrop")
const MENU_BACKDROP_BLUR_PATH := NodePath("CircleMenuBackdrop/BlurRect")
const MENU_BACKDROP_BUFFER_PATH := NodePath("CircleMenuBackdrop/BackBufferCopy")

@export var origin: Origin = Origin.BOTTOM_LEFT:
	set(value):
		origin = value
		_reset_open()

@export var menu_open_icon: Texture:
	set(value):
		menu_open_icon = value
		_menu_button.icon = value

@export var menu_close_icon: Texture:
	set(value):
		menu_close_icon = value
		_close_button.icon = value

@export var menu_stylebox_override: StyleBox:
	set(value):
		menu_stylebox_override = value
		if _menu_backdrop:
			_menu_backdrop.add_theme_stylebox_override("panel", value)

@export var override_degree_offset: int = -1

@export var use_blur: bool = true:
	set(value):
		use_blur = value
		_reset_open()

@export var reload: bool = false:
	set(_value): _reset_open()

@export var reset_closed: bool = false:
	set(_value): _reset_closed()

@export var test_open: bool = false:
	set(_value): open()


var state := BEFORE_OPEN

var _menu_button: Button:
	get: return get_node_or_null(MENU_BUTTON_PATH)

var _close_button: Button:
	get: return get_node_or_null(CLOSE_BUTTON_PATH)

var _menu_backdrop: PanelContainer:
	get: return get_node_or_null(MENU_BACKDROP_PATH)

var _menu_backdrop_blur: ColorRect:
	get: return get_node_or_null(MENU_BACKDROP_BLUR_PATH)

var _menu_backdrop_buffer: BackBufferCopy:
	get: return get_node_or_null(MENU_BACKDROP_BUFFER_PATH)


var _origin_pos: Vector2:
	get: 
		var p = Vector2.ZERO
		match origin:
			Origin.TOP_LEFT     : pass
			Origin.TOP_CENTER   : p.x = size.x / 2
			Origin.TOP_RIGHT    : p.x = size.x
			Origin.CENTER_LEFT  : p.y = size.y / 2
			Origin.CENTER       : p = size / 2
			Origin.CENTER_RIGHT : p = Vector2(size.x, size.y / 2)
			Origin.BOTTOM_LEFT  : p.y = size.y
			Origin.BOTTOM_CENTER: p = Vector2(size.x / 2, size.y)
			Origin.BOTTOM_RIGHT : p = size
		return p

var _menu_origin_pos: Vector2:
	get:
		var mpos := menu_pos
		var msize := menu_size
		match origin:
			Origin.TOP_LEFT     : pass
			Origin.TOP_CENTER   : mpos.x += msize.x / 2
			Origin.TOP_RIGHT    : mpos.x += msize.x
			Origin.CENTER_LEFT  : mpos.y += msize.y / 2
			Origin.CENTER       : mpos += msize / 2
			Origin.CENTER_RIGHT : mpos += Vector2(msize.x, msize.y / 2)
			Origin.BOTTOM_LEFT  : mpos.y += msize.y
			Origin.BOTTOM_CENTER: mpos += Vector2(msize.x / 2, msize.y)
			Origin.BOTTOM_RIGHT : mpos += msize
		return mpos

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

var _origin_deg: int:
	get:
		match origin:
			Origin.TOP_LEFT      : return 230
			Origin.TOP_CENTER    : return 260
			Origin.TOP_RIGHT     : return 300
			Origin.CENTER_LEFT   : return 190
			Origin.CENTER        : return 0
			Origin.CENTER_RIGHT  : return -10
			Origin.BOTTOM_LEFT   : return 160
			Origin.BOTTOM_CENTER : return 100
			Origin.BOTTOM_RIGHT, _: return 40

var _child_nodes: Array[NodePath] = [
	MENU_BUTTON_PATH,
	MENU_BACKDROP_PATH,
	CLOSE_BUTTON_PATH,
]

func _tween(ease: int) -> Tween:
	return (
		get_tree()
			.create_tween()
			.set_ease(ease)
			.set_trans(Tween.TRANS_CUBIC)
			.set_parallel()
		)

enum { BEFORE_OPEN, AFTER_OPEN }

const DEFAULT_PROPS := {
	start = BEFORE_OPEN,
	end = AFTER_OPEN,
	duration = 0.5,
	props = {}
}

func _tween_props(node: Node, props := DEFAULT_PROPS) -> void:
	var ease: int = (
		props.ease if "ease" in props 
		else Tween.EASE_OUT if props.start == BEFORE_OPEN 
		else Tween.EASE_IN
	)
	for prop in props.props.keys():
		node.set(prop, props.props[prop][props.start])
	var tween := _tween(ease)
	for prop in props.props.keys():
		var current_prop = props.props[prop]
		var prop_duration = current_prop.duration if "duration" in current_prop else props.duration
		tween.tween_property(node, prop,current_prop[props.end], prop_duration)
	await tween.finished


func _tween_container(props := DEFAULT_PROPS) -> void:
	props.duration = 1.0
	props.props = {
		"degree_range" : { AFTER_OPEN: degree_range,  BEFORE_OPEN: 0.0 },
		"degree_offset": { AFTER_OPEN: degree_offset, BEFORE_OPEN: degree_offset - 20.0 },
		"extra_margin" : { AFTER_OPEN: extra_margin,  BEFORE_OPEN: extra_margin + radius / 2 }
	}
	_tween_props(self, props)


func _tween_item(item: Control, delay: float, props := DEFAULT_PROPS) -> void:
	var tween := _tween(Tween.EASE_IN_OUT)
	for prop in props.animated.keys():
		tween.tween_property(item, prop, props.animated[prop][state], 0.5)
	await get_tree().create_timer(0.5).timeout


func _tween_menu_button(props := DEFAULT_PROPS) -> void:
	props.duration = 0.25
	props.props = {
		"rotation": { AFTER_OPEN: deg2rad(-10),      BEFORE_OPEN: 0.0, "duration": 0.15 },
		"scale"   : { AFTER_OPEN: Vector2(1.1, 1.1), BEFORE_OPEN: Vector2.ONE },
	}
	await _tween_props(_menu_button, props)
	props.props = {
		"rotation": { AFTER_OPEN: deg2rad(180), BEFORE_OPEN: deg2rad(-10) },
		"scale"   : { AFTER_OPEN: Vector2.ZERO, BEFORE_OPEN: Vector2(1.1, 1.1), "duration": 0.15 },
	}
	_tween_props(_menu_button, props)
	props.props = {
		"rotation": { AFTER_OPEN: 0.0,         BEFORE_OPEN: deg2rad(-60) },
		"scale"   : { AFTER_OPEN: Vector2.ONE, BEFORE_OPEN: Vector2.ZERO },
	}
	await _tween_props(_close_button, props)


func open() -> void:
	_reset_closed()
	_tween_container()
	
	if _menu_button:
		_tween_menu_button()
	
	var delay := 0.05
	for item in get_children():
		if not get_path_to(item) in _child_nodes:
			await get_tree().create_timer(delay).timeout
			_tween_item(item, delay)


func close() -> void:
	pass


func _sort_children() -> void:
	for node_path in _child_nodes:
		if node_path not in unsorted:
			unsorted.append(node_path)
	super._sort_children()


func _reset_open() -> void:
	_reset_nodes(AFTER_OPEN)
	_sort_children()


func _reset_closed() -> void:
	_reset_nodes(BEFORE_OPEN)
	_sort_children()


var _self_props: Dictionary:
	get: return {
		"static": {
			"_temp_degree_offset": _get_degree_offset(),
			"_temp_extra_margin": extra_margin,
			"_temp_degree_range": degree_range,
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
				BEFORE_OPEN: extra_margin + radius / 2,
				AFTER_OPEN: extra_margin,
			}
		}
	}


var _menu_button_props: Dictionary:
	get: return {
		"static": {
			"position": (
				_to_circle_pos(center, radius / 3, _origin_deg) 
					if origin != Origin.CENTER 
					else _to_menu_origin(_menu_button, true)
			),
			"pivot_offset": _menu_button.size / 2,
		},
		"animated": {
			"rotation": {
				BEFORE_OPEN: 0.0,
				AFTER_OPEN: deg2rad(-60),
			},
			"scale": {
				BEFORE_OPEN: Vector2.ONE,
				AFTER_OPEN: Vector2.ZERO
			}
		}
	}

var _close_button_props: Dictionary:
	get: return {
		"static": {
			"position": (
				_to_circle_pos(center, radius / 3, _origin_deg) 
					if origin != Origin.CENTER 
					else _to_menu_origin(_close_button, true)
			),
			"pivot_offset": _close_button.size / 2,
		},
		"animated": {
			"rotation": {
				BEFORE_OPEN: deg2rad(-60),
				AFTER_OPEN: 0.0,
			},
			"scale": {
				BEFORE_OPEN: Vector2.ZERO,
				AFTER_OPEN: Vector2.ONE
			}
		}
	}


var _menu_backdrop_props: Dictionary:
	get: return {
		"static": {
			"size": menu_size,
			"position": menu_pos,
		},
		"animated": {}
	}

var _menu_backdrop_buffer_props: Dictionary:
	get: return {
		"static": {
			"rect": Rect2(Vector2.ZERO, menu_size)
		},
		"animated": {}
	}

func _item_props(item: Control) -> Dictionary: 
	return {
		"static": {
			"pivot_offset": item.size / 2
		},
		"animated": {
			"scale": { 
				BEFORE_OPEN: Vector2.ZERO,
				AFTER_OPEN: Vector2.ONE,
			},
			"rotation": { 
				BEFORE_OPEN: deg2rad(-180),
				AFTER_OPEN: 0.0,
			},
		}
	}


var _node_props: Dictionary:
	get: 
		var list := {
			self: _self_props,
			_menu_button: _menu_button_props,
			_menu_backdrop: _menu_backdrop_props,
			_close_button: _close_button_props,
			_menu_backdrop_buffer: _menu_backdrop_buffer_props
		}
		for child in get_children():
			if get_path_to(child) not in _child_nodes:
				list[child] = _item_props(child)
		return list


func _reset_nodes(state := BEFORE_OPEN) -> void:	
	for node in _node_props.keys():
		var props = _node_props[node]
		for prop in props["static"].keys():
			node.set(prop, props["static"][prop])
		for prop in props.animated.keys():
			node.set(prop, props.animated[prop][state])


func _reset() -> void:
	_reset_nodes(AFTER_OPEN)
	_sort_children()


func _get_degree_offset() -> int:
	if override_degree_offset < 0:
		var offset = (360 - degree_range) / 2
		match origin:
			Origin.TOP_LEFT     : offset += 200
			Origin.TOP_CENTER   : offset += 240
			Origin.TOP_RIGHT    : offset += 280
			Origin.CENTER_LEFT  : offset += 140
			Origin.CENTER       : offset += 80 
			Origin.CENTER_RIGHT : offset += 330
			Origin.BOTTOM_LEFT  : offset += 110
			Origin.BOTTOM_CENTER: offset += 80 
			Origin.BOTTOM_RIGHT : offset += 20 
		return offset
	else: 
		return override_degree_offset


func _to_menu_origin(node: Control, with_margin: bool = false) -> void:
	if node: node.position = _get_node_origin_pos(_menu_origin_pos, node, with_margin)


func _get_node_origin_pos(from: Vector2, node: Control, with_margin: bool = false) -> Vector2:
	var m := Vector2(extra_margin, extra_margin) if with_margin else Vector2.ZERO
	if node:
		match origin:
			Origin.TOP_LEFT     : from += m
			Origin.TOP_CENTER   : 
				from.x -= (node.size.x / 2)
				from.y += m.y
			Origin.TOP_RIGHT    : 
				from.x -= (node.size.x + m.x)
				from.y += m.y
			Origin.CENTER_LEFT  : 
				from.y -= (node.size.y / 2)
				from.x += m.x
			Origin.CENTER       : from -= (node.size / 2)
			Origin.CENTER_RIGHT : 
				from -= Vector2(node.size.x, (node.size.y / 2))
				from.x -= m.x
			Origin.BOTTOM_LEFT  : 
				from.y -= (node.size.y + m.y)
				from.x += m.x
			Origin.BOTTOM_CENTER: 
				from -= Vector2((node.size.x / 2), node.size.y)
				from.y -= m.y
			Origin.BOTTOM_RIGHT : from -= (node.size + m)
	return from
