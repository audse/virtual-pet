extends VBoxContainer

@export var traits_data: TraitsData:
	set(value):
		traits_data = value
		connect_all()

@onready var container := %TraitsContainer as HFlowContainer
@onready var num_selected_label := %NumSelectedLabel as Label
@onready var random_button := %RandomTraitsButton as Button

var trait_nodes := {}


func _ready() -> void:
	for t in TraitsData.PersonalityTrait.values():
		trait_nodes[t] = Ui.tag_button(TraitsData.get_trait_name(t))
		container.add_child(trait_nodes[t])
	
	if traits_data: 
		connect_all()
		update_trait_labels()


func connect_all() -> void:
	if traits_data and is_inside_tree():
		traits_data.traits_changed.connect(update_trait_labels)
		random_button.pressed.connect(traits_data.generate_random)
		for t in trait_nodes.keys():
			trait_nodes[t].pressed.connect(traits_data.toggle_trait.bind(t))


func update_trait_labels() -> void:
	var num_selected := traits_data.traits.size()
	
	for t in trait_nodes.keys():
		var is_selected: bool = t in traits_data.traits
		trait_nodes[t].theme_type_variation = (
			"TagButton_Selected" 
			if is_selected
			else "TagButton"
		)
		trait_nodes[t].disabled = not is_selected and num_selected == traits_data.num_allowed_traits
	
	num_selected_label.text = "{selected} / {available} selected".format({
		selected = num_selected,
		available = traits_data.num_allowed_traits
	})


func validate() -> bool:
	return traits_data.traits.size() == traits_data.num_allowed_traits
