extends Node

const data_path := "user://datetime_data.tres"

var timer: Timer
var data := DatetimeData.new()


func _ready() -> void:
	load_data()
	
	# save data whenever it's changed
	data.time_changed.connect(func(_time) -> void: save_data())
	data.day_changed.connect(func(_day) -> void: save_data())
	
	data.time_changed.emit(data.time)
	
	create_timer()


func connect_timer_to_pause(timer_node: Timer) -> void:
	# Pauses the provided timer whenever the datetime is paused, 
	# and resumes when the datetime is unpaused
	data.time_paused.connect(
		func() -> void:
			timer_node.stop()
			await data.time_unpaused
			timer_node.start()
	)


func create_timer() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = data.INTERVAL_TIME
	timer.timeout.connect(
		func() -> void: data.time += data.UNIT
	)
	connect_timer_to_pause(timer)
	timer.start()


func load_data() -> void:
	if ResourceLoader.exists(data_path):
		data = ResourceLoader.load(data_path)


func save_data() -> void:
	ResourceSaver.save(data, data_path)
