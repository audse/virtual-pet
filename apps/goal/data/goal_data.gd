class_name GoalData
extends SaveableResource

signal activated
signal deactivated
signal progress_made
signal completed

enum Source {
	TUTORIAL,
	DAILY,
	LIFETIME,
	EVENT,
}

@export var id: String
@export var display_title: String
@export var description: String
@export var source: Source
@export var reward := RewardData.new()

@export var total: int = 5
@export var progress: int = 0:
	set(value):
		progress = value
		if progress == total:
			complete = true
			completed.emit()
		else: progress_made.emit()

@export var active: bool = false:
	set(value):
		active = value
		if active: activated.emit()
		else: deactivated.emit()

@export var complete: bool = false:
	set(value):
		complete = value
		if complete: completed.emit()


func _init(args := {}) -> void:
	for key in args.keys():
		if key in self: self[key] = args[key]
	super._init()


func setup():
	for sig in [reward.changed, progress_made, activated, deactivated, completed]:
		if not sig.is_connected(emit_changed): sig.connect(emit_changed)
	super.setup()
	return self


func _get_dir() -> String:
	return "goals"
