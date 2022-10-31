class_name GameModeState
extends State

enum GameMode {
	LIVE,
	BUILD,
	BUY,
}

var mode := GameMode.LIVE

var is_paused: bool:
	get: return mode != GameMode.LIVE
