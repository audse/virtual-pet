class_name RewardData
extends Resource

signal claimed

@export var fate: int = 100

# TODO other reward types, e.g. objects, unlock designs

@export var is_claimed: bool = false


func claim() -> void:
	is_claimed = true
	Fate.data.fate += fate
	Fate.data.earn(FateData.ReasonForEarning.GOAL_COMPLETE)
	
	claimed.emit()
	emit_changed()
