class_name Button3D
extends MeshInstance3D

signal mouse_entered
signal mouse_exited
signal pressed
signal released
signal disabled_changed(bool)
signal draw_mode_changed(int)

enum Facing {
	UP,
	FORWARD,
	SIDE,
}

@export var text: String
@export var facing: Facing = Facing.FORWARD
@export var size: Vector2
@export var pixel_scale: float = 0.01

@export var disabled: bool = false:
	set(value):
		disabled = value
		disabled_changed.emit(value)

@export_group("Theme")
@export var theme_type_variation: String = "Button"
@export_enum(HORIZONTAL_ALIGNMENT_LEFT, HORIZONTAL_ALIGNMENT_CENTER, HORIZONTAL_ALIGNMENT_RIGHT) var label_h_alignment = HORIZONTAL_ALIGNMENT_CENTER
@export_enum(VERTICAL_ALIGNMENT_TOP, VERTICAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_BOTTOM) var label_v_alignment = VERTICAL_ALIGNMENT_CENTER

@onready var viewport: Viewport = get_viewport()
@onready var camera: Camera3D = viewport.get_camera_3d() if viewport else null

var label := Label3D.new()
var aabb: AABB

var draw_mode: int = BaseButton.DRAW_NORMAL:
	set(value):
		draw_mode = value
		draw_mode_changed.emit(draw_mode)

var theme: Theme = ThemeDB.get_project_theme()
var stylebox_normal: StyleBoxFlat = theme.get_stylebox("normal", theme_type_variation)
var stylebox_hover: StyleBoxFlat = theme.get_stylebox("hover", theme_type_variation)
var stylebox_pressed: StyleBoxFlat = theme.get_stylebox("pressed", theme_type_variation)
var stylebox_disabled: StyleBoxFlat = theme.get_stylebox("disabled", theme_type_variation)

var color_normal: Color = theme.get_color("font_color", theme_type_variation)
var color_hover: Color = theme.get_color("font_hover_color", theme_type_variation)
var color_pressed: Color = theme.get_color("font_pressed_color", theme_type_variation)
var color_disabled: Color = theme.get_color("font_disabled_color", theme_type_variation)

var font: Font = theme.get_font("font", theme_type_variation)

var font_size_normal: int = theme.get_font_size("normal", theme_type_variation)
var font_size_hover: int = theme.get_font_size("hover", theme_type_variation)
var font_size_pressed: int = theme.get_font_size("pressed", theme_type_variation)
var font_size_disabled: int = theme.get_font_size("disabled", theme_type_variation)


func _init(args := {}) -> void:
	for key in args.keys(): if key in self: self[key] = args[key]


func _enter_tree() -> void:
	add_child(label)
	
	pressed.connect(
		func() -> void: draw_mode = BaseButton.DRAW_PRESSED
	)
	released.connect(
		func() -> void: draw_mode = BaseButton.DRAW_NORMAL
	)
	disabled_changed.connect(
		func(val) -> void: draw_mode = BaseButton.DRAW_NORMAL if not val else BaseButton.DRAW_DISABLED
	)
	mouse_entered.connect(
		func() -> void: draw_mode = BaseButton.DRAW_HOVER
	)
	mouse_exited.connect(
		func() -> void: draw_mode = BaseButton.DRAW_NORMAL
	)
	
	draw_mode_changed.connect(draw)
	draw(draw_mode)


func _unhandled_input(event: InputEvent) -> void:
	if not camera or draw_mode == BaseButton.DRAW_DISABLED: return
	
	if event is InputEventMouseMotion:
		if draw_mode == BaseButton.DRAW_NORMAL and has_point(event.position):
			mouse_entered.emit()
		elif draw_mode == BaseButton.DRAW_HOVER and not has_point(event.position):
			mouse_exited.emit()
	
	if event is InputEventMouseButton:
		if event.is_pressed() and has_point(event.position):
			pressed.emit()
		elif draw_mode == BaseButton.DRAW_PRESSED and not event.pressed:
			released.emit()


func has_point(point: Vector2) -> bool:
	var origin := camera.project_ray_origin(point)
	var pos := Vector3Ref.project_position_to_floor(camera, point)
	return aabb.intersects_segment(origin, pos) != null


func get_stylebox(mode: int) -> StyleBoxFlat:
	match mode:
		BaseButton.DRAW_PRESSED: return stylebox_pressed
		BaseButton.DRAW_HOVER: return stylebox_hover
		BaseButton.DRAW_DISABLED: return stylebox_disabled
		_: return stylebox_normal


func get_font_color(mode: int) -> Color:
	match mode:
		BaseButton.DRAW_PRESSED: return color_pressed
		BaseButton.DRAW_HOVER: return color_hover
		BaseButton.DRAW_DISABLED: return color_disabled
		_: return color_normal


func get_font_size(mode: int) -> int:
	match mode:
		BaseButton.DRAW_PRESSED: return font_size_pressed
		BaseButton.DRAW_HOVER: return font_size_hover
		BaseButton.DRAW_DISABLED: return font_size_disabled
		_: return font_size_normal


func draw(mode: int) -> void:
	var stylebox := get_stylebox(mode)
	update_label(mode)
	
	# Update mesh
	mesh = generate_mesh(stylebox)
	aabb = mesh.get_aabb().grow(0.05)
	if mesh.get_surface_count() > 0:
		mesh.surface_set_material(0, generate_material(stylebox))


func update_label(mode: int) -> void:
	var stylebox := get_stylebox(mode)
	
	label.text = text
	label.modulate = get_font_color(mode)
	label.font_size = get_font_size(mode) * 4
	label.font = font
	label.outline_size = 0
	label.no_depth_test = true
	
	var label_aabb := label.get_aabb()
	
	var world_offset := size / 2
	match label_h_alignment:
		HORIZONTAL_ALIGNMENT_RIGHT: world_offset.x += -(label_aabb.size.x / 2) + (stylebox.content_margin_left * pixel_scale)
		HORIZONTAL_ALIGNMENT_LEFT: world_offset.x += (label_aabb.size.x / 2) - (stylebox.content_margin_left * pixel_scale)
	match label_v_alignment:
		VERTICAL_ALIGNMENT_TOP: world_offset.y += -(label_aabb.size.y / 2) + (stylebox.content_margin_top * pixel_scale)
		VERTICAL_ALIGNMENT_BOTTOM: world_offset.y += (label_aabb.size.y / 2) - (stylebox.content_margin_top * pixel_scale)
	
	match facing:
		Facing.FORWARD:
			label.position = Vector3(world_offset.x, world_offset.y, 0.0)
		Facing.UP: 
			label.position = Vector3(world_offset.x, 0.0, world_offset.y)
			label.rotation.x = -deg_to_rad(90)
		Facing.SIDE: 
			label.position = Vector3(0.0, world_offset.x, world_offset.y)
			label.rotation.y = deg_to_rad(90)


func generate_mesh(stylebox: StyleBoxFlat) -> ArrayMesh:
	var radius := stylebox.corner_radius_top_left * pixel_scale
	var expand := stylebox.expand_margin_top * pixel_scale
	var rect := Rect2(
		Vector2(-expand, -expand), 
		size + Vector2(expand, expand) * 2
	)
	return ProcMesh.new_rounded_plane(rect, ProcMeshParams.new({
		corner_radius = radius,
		corner_points = stylebox.corner_detail,
		facing = (
			Vector3.FORWARD if facing == Facing.FORWARD 
			else Vector3.UP if facing == Facing.UP 
			else Vector3.LEFT
		)
	}))


func generate_material(stylebox: StyleBoxFlat, unshaded := true) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = stylebox.bg_color
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	transparency = 1.0 - stylebox.bg_color.a
	if unshaded: mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if label: label.shaded = not unshaded
	return mat
