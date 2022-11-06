extends AddBuyableObjectsModule


const parent_class := "res://apps/buy/data/buy_data.gd"


func get_data_paths() -> Array[String]:
	return [
		"more_plants_pack/plant_2.json",
		"more_plants_pack/plant_5.json",
		"more_plants_pack/plant_14.json",
	]
