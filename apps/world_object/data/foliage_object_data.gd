class_name FoliageData
extends WorldObjectData

enum FoliageType {
	TREE,
	BUSH,
	GRASS,
}

enum LifeStage {
	JUST_PLANTED,
	BABY,
	GROWING,
	ADULT,
}

@export var type: FoliageType
@export var stage: LifeStage


#func _init() -> void:
#	item_data.layer = WorldObjectData.Layer.FOLIAGE_LAYER
	
	# grass is an automatic food source
#	if type == FoliageType.GRASS:
#		flags.append(WorldObjectData.Flag.HUNGER_SOURCE)
