extends ActionItemScript

const AddTraits := preload("add_traits.gd")

func run(action_item: ActionItem, context: Node, _extra_args := {}) -> void:
	var add_traits_func = AddTraits.new().run.bind(context, {})
	if action_item.args.submenu.get_child_count() < TraitsData.PersonalityTrait.size():
		var trait_actions: Array[ActionItemParams] = TraitsData.PersonalityTrait.keys().map(
			func(name: String) -> ActionItemParams: return ActionItemParams.new({
				id = TraitsData.PersonalityTrait[name],
				text = name.replace("_", " ").to_lower(),
				on_pressed = add_traits_func.bind(context)
			})
		)
		(action_item.args.submenu as ActionMenu).append_actions(trait_actions)
