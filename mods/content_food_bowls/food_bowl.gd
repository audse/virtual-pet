extends ConsumableObject

const REFILL_COST := 50
const REFILL_ACTION_ID := "food_bowl_1__refill"

const FilledMesh: Mesh = preload("meshes/food_bowl_1__filled.tres")
const PartiallyEatenMesh: Mesh = preload("meshes/food_bowl_1__partially_eaten.tres")
const EatenMesh: Mesh = preload("meshes/food_bowl_1__eaten.tres")

var Meshes := {
	2: FilledMesh,
	1: PartiallyEatenMesh,
	0: EatenMesh,
}

var food_mesh := MeshInstance3D.new()


func _ready() -> void:
	add_child(food_mesh)
	super._ready()


func reset() -> void:
	Fate.data.fate -= REFILL_COST
	# TODO animation
	super.reset()


func update_all() -> void:
	_update_mesh()
	update_action_item()


func update_action_item() -> void:
	if not context: return
	var has_item: bool = context.action_menu.has_action(REFILL_ACTION_ID)
	var can_use: bool = context.object_data.can_use()
	
	if not has_item:
		context.action_menu.action_menu.append_action(
			ActionItemParams.new({
				id = REFILL_ACTION_ID,
				text = "refill bowl for {0}".format([REFILL_COST]),
				on_pressed = _on_refill_pressed
			})
		)
	context.action_menu.action_menu.actions[REFILL_ACTION_ID].button.disabled = can_use


func _update_mesh() -> void:
	# TODO animation
	if context and context.object_data:
		food_mesh.mesh = _get_mesh(context.object_data.uses_left)


func _get_mesh(uses_left: int) -> Mesh:
	if context and context.object_data:
		return Meshes[uses_left]
	return null


func _on_context_changed() -> void:
	update_all()
	if not context.object_data.uses_left_changed.is_connected(update_all):
		context.object_data.uses_left_changed.connect(
			func(_uses): update_all()
		)


func _on_refill_pressed(_action_item: ActionItem) -> void:
	context.object_data.reset_uses()
