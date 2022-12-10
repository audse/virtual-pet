class_name GoalData
extends SaveableResource

signal activated
signal deactivated
signal progress_made
signal completed

enum Source {
	GAMEPLAY = -1,
	TUTORIAL,
	DAILY,
	LIFETIME,
	EVENT,
}

@export var id: String
@export var display_title: String
@export var description: String
@export var source: Source = Source.GAMEPLAY
@export var reward := RewardData.new()

## The date in which this goal will become active, in in-game time. 
## A value of -1 indicates an immediately activated goal.
@export var activation: int = -1

## The date in which this goal will cease to be active, in in-game time. 
## A value of -1 indicates that the goal will never expire.
@export var expiration: int = -1

@export var uses_in_game_clock := false

## If `true`, the expiration date will be counted from the moment the goal is activated. 
## Otherwise, it will be counted from the beginning of game or beginning of time, depending on `uses_in_game_clock`
@export var expiration_is_relative := false

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
