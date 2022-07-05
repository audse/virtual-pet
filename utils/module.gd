extends Node

const UseSpacialTiles: Script = preload("res://apps/map/nodes/cell_map/use_spacial_tiles.gd")


var ids := {
	UseSpacialTiles: "use_spacial_tiles"
}

var _cached_modules := {}


func inject(kwargs: Dictionary, script: Script, context: Node = null) -> void:
	var module := _get_cached(script, context)
	for keyword in kwargs.keys():
		module.set(keyword, kwargs[keyword])


func import_method(callable_name: String, from: Script, context: Node = null) -> Callable:
	var script_class = _get_cached(from, context)
	if script_class.has_method(callable_name):
		var callable := Callable(script_class, callable_name)
		return callable
	return Callable()


func import(from: Script, context: Node = null) -> Object:
	return _get_cached(from, context)


func _inject_context(module: Object, context: Node = null) -> void:
	if not module or not context: return
	
	if module.has_method("_init_inject"):
		module._init_inject(context)
	
	if module.has_method("_enter_tree_inject") and context.has_signal("tree_entered"): 
		context.tree_entered.connect(module._enter_tree_inject.bind(context))
	
	if module.has_method("_ready_inject") and  context.has_signal("ready"): 
		context.ready.connect(module._ready_inject.bind(context))


func _get_cached(script: Script, context: Node = null) -> Object:
	var module: Object
	
	var id: String = ids[script] if script in ids else ""
	if not id in _cached_modules: _cached_modules[id] = {}
	
	var context_id: int = -1
	if context: context_id = context.get_instance_id()
	
	if context_id in _cached_modules[id]:
		module = _cached_modules[id][context_id]
	else:
		module = script.new()
		_cached_modules[id][context_id] = module
	
	if context: _inject_context(module, context)
	return module
