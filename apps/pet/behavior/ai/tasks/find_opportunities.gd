extends Task


func run() -> void:
	if tree.pet_data:
		var opportunity: OpportunityData = WorldData.find_nearby_opportunities(tree.pet_data).pop_front()
		if opportunity:
			logs("Found opportunity! \n" + opportunity.describe())
			
			var want = opportunity.detail[OpportunityData.Objective.FULFILL_WANT]
			var need = opportunity.detail[OpportunityData.Objective.FULFILL_NEED]
			var command := CommandData.Command.IDLE
			
			if need != null: command = CommandData.CommandToNeedMap[need]
			
			match want:
				WantsData.Want.EAT_RARE_FOOD: command = CommandData.Command.EAT
				WantsData.Want.PLAY_WITH_RARE_TOY: command = CommandData.Command.PLAY
				WantsData.Want.LOUNGE_ON_RARE_BED: command = CommandData.Command.LOUNGE
				WantsData.Want.SLEEP_ON_RARE_BED: command = CommandData.Command.SLEEP
				WantsData.Want.PLAY_WITH_FRIEND: 
					command = CommandData.Command.PLAY_TOGETHER
					# Also send command to friend
					opportunity.nearby_pet.command_data.receive_command.emit(command, opportunity.nearby_object)
			
			# Complete the task
			tree.pet_data.command_data.start_command.emit(command, opportunity.nearby_object)
			await tree.pet_data.command_data.finish_command
		
			return succeed()
	fail()
