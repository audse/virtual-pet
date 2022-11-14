class_name GameModeState
extends State

enum Mode {
	LIVE,
	BUILD,
	BUY,
}

var is_live: bool:
	get: return state == Mode.LIVE

var is_build: bool:
	get: return state == Mode.BUILD

var is_buy: bool:
	get: return state == Mode.BUY

var is_paused: bool:
	get: return state != Mode.LIVE


func set_to(next_state: int) -> void:
	Datetime.data.paused = next_state != Mode.LIVE
	super.set_to(next_state)
