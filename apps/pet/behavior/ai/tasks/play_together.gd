extends Task

var friend: PetData
var toy: WorldObjectData


func run() -> void:		
	# Complete the task
	tree.pet_data.command_data.start_command.emit(CommandData.Command.PLAY_TOGETHER, toy)
	await tree.pet_data.command_data.finish_command
	
	tree.leaf_task_finished.emit(self)
	succeed()
