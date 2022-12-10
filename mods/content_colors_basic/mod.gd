extends AddPetColorsModule

const ParentClass := "Game.Data"


func get_data_paths() -> Array[String]:
    return [
        "content_colors_basic/json/color_white.json",
        "content_colors_basic/json/color_black.json"
    ]