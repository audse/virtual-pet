class_name AnimalData
extends Resource

enum Animal {
	DOG
}

signal animal_changed(animal: Animal)
signal color_changed(color: PetColorData)

@export var animal: Animal = Animal.DOG:
	set(value):
		animal = value
		animal_changed.emit(animal)
		emit_changed()

@export var color := PetColorData.new():
	set(value):
		color = value
		color_changed.emit(color)
		emit_changed()
