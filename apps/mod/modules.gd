extends Node

const ModPortal: PackedScene = preload("res://apps/mod/interface/mod_portal.tscn")
const UseSpacialTiles: Script = preload("res://apps/map/nodes/cell_map/use_spacial_tiles.gd")


var ids := {
	UseSpacialTiles: "use_spacial_tiles"
}

var _cached_modules := {}

var registered_modules := {}


func _init() -> void:
	var mods_folder = DirAccess.open("res://mods")
	
	for mod_name in mods_folder.get_directories():
		print("[Mod: " + mod_name + "] Loading...")
		
		var mod_path := "res://mods/" + mod_name
		var mod_zip := FileAccess.open(mod_path + "/mod.zip", FileAccess.READ)
		
		if mod_zip: ProjectSettings.load_resource_pack(mod_zip.get_path_absolute(), false)
		if FileAccess.file_exists(mod_path + "/mod.gd"):
			print("[Mod: " + mod_name + "] Script found!")
			
			var mod_script := load(mod_path + "/mod.gd")
			var constants := (mod_script as Script).get_script_constant_map()
			registered_modules[mod_name] = {
				name = mod_name,
				scripts = [mod_script],
				parent_classes = [
					ModHooks.get_class_path(constants.ParentClass)
				],
				is_cheat = [
					constants.IsCheat if "IsCheat" in constants else false
				]
			}
		else:
			if DirAccess.dir_exists_absolute(mod_path + "/mod"):
				print("[Mod: " + mod_name + "] Multiple scripts found!")
				var mod_script_folder := DirAccess.open(mod_path + "/mod")
				var mod_script_paths := mod_script_folder.get_files() as Array[String]
				
				var mod_scripts = []
				var parent_classes = []
				var is_cheat = []
				for mod_script_path in mod_script_paths:
					var script = load(mod_path + "/mod/" + mod_script_path)
					var constants = script.get_script_constant_map()
					mod_scripts.append(script)
					parent_classes.append(ModHooks.get_class_path(constants.ParentClass))
					is_cheat.append(constants.IsCheat if "IsCheat" in constants else false)
				
				registered_modules[mod_name] = {
					name = mod_name,
					scripts = mod_scripts,
					parent_classes = parent_classes,
					is_cheat = is_cheat,
				}


func accept_modules(context: Node) -> void:
	var context_script_path: String = context.get_script().resource_path
	for mod in registered_modules.values():
		# Skip accepting disabled mods
		if mod.name in Settings.data.disabled_mods: 
			print("[Mod: " + mod.name + "] Disabled, skipping...")
			continue
		
		var i := 0
		for script in mod.scripts:
			# Skip cheat mods if they're disabled
			if Settings.data.disable_cheat_mods and mod.is_cheat[i]:
				i += 1
				continue
			if mod.parent_classes[i] == context_script_path:
				print("[Mod: " + mod.name + "] Accepted script `"+ script.resource_path +"`!")
				import(script as Script, context)
			i += 1


func import(from: Script, context: Node = null) -> Object:
	return _get_cached(from, context)


func import_method(callable_name: String, from: Script, context: Node = null) -> Callable:
	var script_class = _get_cached(from, context)
	if script_class.has_method(callable_name):
		var callable := Callable(script_class, callable_name)
		return callable
	return Callable()


func _inject_context(module: Module, context: Node = null) -> void:
	if not module or not context: return
	
	module._on_init(context)
	
	if context.has_signal("tree_entered"): 
		context.tree_entered.connect(module._on_enter_tree.bind(context))
	
	if context.has_signal("ready"): 
		context.ready.connect(module._on_ready.bind(context))
	
	if context.has_signal("gui_input"): 
		context.gui_input.connect(module._on_gui_input.bind(context))


func _get_cached(script: Script, context: Node = null) -> Object:
	var module: Object
	
	var id: String = ids[script] if script in ids else script.resource_path
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


func go_to_portal() -> void:
	get_tree().change_scene_to_packed(ModPortal)
