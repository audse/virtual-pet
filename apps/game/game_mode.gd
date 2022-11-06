class_name GameModeState
extends State

enum GameMode {
	LIVE,
	BUILD,
	BUY,
}

var is_live: bool:
	get: return state == GameMode.LIVE

var is_paused: bool:
	get: return state != GameMode.LIVE


func set_to(next_state: int) -> void:
	Datetime.data.paused = next_state != GameMode.LIVE
	super.set_to(next_state)
