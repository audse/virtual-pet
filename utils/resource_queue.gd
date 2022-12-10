extends Node

signal all_loaded
signal loaded(String, Resource)

var is_started: bool = false

var queued: Array[String] = []
# Dictionary[String, Callable]
var callbacks: Dictionary = {}

func _ready() -> void:
	start()


func _process(_delta: float) -> void:
	if queued.size() == 0: return
	if ResourceLoader.load_threaded_get_status(queued[0]) == ResourceLoader.THREAD_LOAD_LOADED:
		var path: String = queued.pop_front()
		var data: Resource = ResourceLoader.load_threaded_get(path)
		loaded.emit(path, data)


func queue(path: String, callback: Callable = func(_path, _res): pass) -> void:
	queued.append(path)
	callbacks[path] = callback
	if not is_started: start()


func start() -> void:
	if not loaded.is_connected(_on_loaded):
		loaded.connect(_on_loaded)
	is_started = true
	start_next()


func stop() -> void:
	loaded.disconnect(_on_loaded)
	is_started = false


func start_next() -> void:
	if queued.size() == 0: 
		all_loaded.emit()
		is_started = false
		return
	ResourceLoader.load_threaded_request(queued[0])


func _on_loaded(path: String, resource: Resource) -> void:
	start_next()
	
	if path in callbacks and callbacks[path] is Callable:
		callbacks[path].call(path, resource)
		callbacks.erase(path)
