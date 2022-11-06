class_name FateData
extends Resource

signal fate_changed(value: int)

@export var fate: int = 0:
	set(value):
		fate = value
		fate_changed.emit(value)


enum ReasonForEarning {
	GAVE_COMMAND,
	GAVE_OBJECT,
	CUDDLED,
	HAPPY_PET,
}


const EarnAmount := {
	ReasonForEarning.GAVE_COMMAND: 10,
	ReasonForEarning.GAVE_OBJECT: 50,
	ReasonForEarning.CUDDLED: 10,
	ReasonForEarning.HAPPY_PET: 10,
}


func earn(reason: ReasonForEarning) -> void:
	fate += EarnAmount[reason]
