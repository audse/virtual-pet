class_name HandleNeedTask
extends Task

@export var need: NeedsData.Need

var command: CommandData.Command:
	get: return {
		NeedsData.Need.ACTIVITY: CommandData.Command.PLAY,
		NeedsData.Need.COMFORT: CommandData.Command.LOUNGE,
		NeedsData.Need.HUNGER: CommandData.Command.EAT,
		NeedsData.Need.HYGIENE: CommandData.Command.WASH,
		NeedsData.Need.SLEEPY: CommandData.Command.SLEEP,
	}[need]


func run() -> void:
	var need_source: WorldObjectData = WorldData.find_nearby_need_source(tree.pet_data, need, tree.pet_data.world_coord)
	if need_source:
		logs("Need fulfilling object found at {0}".format([need_source.coord]))
		
		# Claim the tile so that no other pets try to occupy it
		need_source.flags.append(WorldObjectData.Flag.CLAIMED)
		
		# Complete the task
		tree.pet_data.command_data.start_command.emit(command, need_source)
		await tree.pet_data.command_data.finish_command
		
		# Release the claim on the tile
		# TODO sometimes they just stay on this tile, causing problems...
		need_source.flags.erase(WorldObjectData.Flag.CLAIMED)
		
		tree.leaf_task_finished.emit(self)
		succeed()
	else:
		logs("Need fulfilling object not found nearby.")
		fail()
