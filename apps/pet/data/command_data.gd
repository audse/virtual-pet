class_name CommandData
extends Resource

enum Command {
	IDLE,
	EAT,
	SLEEP,
	PLAY,
	WASH,
	LOUNGE,
}

## emitted when the user has selected a command
signal receive_command(command: Command)

## emitted when the pet AI has decided to do something
signal start_command(command: Command, target: WorldObjectData)

## emitted when the pet has finished doing something
signal finish_command(command: Command)


signal obeyed_command(command: Command)
signal ignored_command(command: Command)

const CommandToNeedMap := {
	NeedsData.Need.ACTIVITY: Command.PLAY,
	NeedsData.Need.COMFORT: Command.LOUNGE,
	NeedsData.Need.HUNGER: Command.EAT,
	NeedsData.Need.HYGIENE: Command.WASH,
	NeedsData.Need.SLEEPY: Command.SLEEP,
}
