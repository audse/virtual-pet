class_name ItemPreview
extends StaticBody3D

@export var animate_hover: bool = true

var item: ItemData

var is_hovering: bool = false
var time_since_hover: float = 0.0
var show_price_label: bool = false

var mesh: MeshInstance3D
var collision: CollisionShape3D


func _init(item_value: ItemData, show_price_value := false) -> void:
	item = item_value
	show_price_label = show_price_value


func _ready() -> void:
	input_ray_pickable = true
	render()


func _physics_process(delta: float) -> void:
	if animate_hover:
		if is_hovering:
			time_since_hover += delta
			mesh.position.y = lerpf(mesh.position.y, 0.5, clampf(time_since_hover / 0.5, 0.0, 1.0))
		else: mesh.position.y = lerpf(mesh.position.y, 0.0, 0.1)
		collision.position = mesh.position


func render() -> void:
	if mesh: remove_child(mesh)
	if collision: remove_child(collision)
	
	if item and item.physical_data:
		var nodes := item.physical_data.render(self, true)
		mesh = nodes.mesh_instance
		collision = nodes.collision_instance
		
		# Move origin of mesh to corner instead of center
		mesh.position = Vector3(
			item.physical_data.dimensions.x as float / 2, 
			0, 
			item.physical_data.dimensions.z as float / 2
		)
		if collision:
			collision.position = mesh.position
	
	if animate_hover:
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
	
	if show_price_label and item is BuyableItemData: 
		add_price_label()


func add_price_label() -> void:
	var text := str((item as BuyableItemData).price)
	var dimensions := item.physical_data.dimensions
	var label_size := Vector2(0.4 * text.length(), 0.5)
	var button := Button3D.new({
		text = text,
		position = Vector3(dimensions.x - label_size.x / 2, -0.05, dimensions.z - label_size.y / 2),
		size = label_size,
		pixel_scale = 0.005,
		facing = Button3D.Facing.UP
	})
	add_child(button)


func _on_mouse_entered() -> void:
	is_hovering = true


func _on_mouse_exited() -> void:
	is_hovering = false
	time_since_hover = 0.0
