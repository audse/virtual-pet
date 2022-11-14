extends PanelContainer

@export var goal_data: GoalData:
	set(value):
		goal_data = value
		if is_inside_tree(): 
			update_goal_data()
			reconnect()


@onready var collect_goal_icon := %CollectGoalIcon as TextureRect
@onready var sell_goal_icon := %SellGoalIcon as TextureRect
@onready var cuddle_goal_icon := %CuddleGoalIcon as TextureRect

@onready var title := %Title as Label
@onready var description := %Description as Label
@onready var progress_bar := %ProgressBar as ProgressBar

@onready var rewards_container := %RewardsContainer as HBoxContainer
@onready var claim_reward_button := %ClaimRewardButton as Button
@onready var fate_reward_container := %FateRewardContainer as VBoxContainer
@onready var fate_amount_label := %FateAmountLabel as Label


func _ready() -> void:
	update_goal_data()
	reconnect()


func update_goal_data() -> void:
	if goal_data:
		for icon in [collect_goal_icon, sell_goal_icon, cuddle_goal_icon]:
			icon.visible = false
		
		if goal_data is CollectGoalData:
			collect_goal_icon.visible = true
		elif goal_data is SellGoalData:
			sell_goal_icon.visible = true
		elif goal_data is CuddleGoalData:
			cuddle_goal_icon.visible = true
		
		if goal_data.reward.fate <= 0:
			fate_reward_container.visible = false
		fate_amount_label.text = str(goal_data.reward.fate)
		
		title.text = goal_data.display_title
		description.text = goal_data.description
		
		update_progress_bar()
		
		if goal_data.active: activate()
		else: deactivate()
		
		if goal_data.complete: complete()
		if goal_data.reward.is_claimed: reward_claimed()


func reconnect() -> void:
	if goal_data:
		goal_data.progress_made.connect(update_progress_bar)
		goal_data.completed.connect(complete)
		goal_data.activated.connect(activate)
		goal_data.deactivated.connect(deactivate)
		goal_data.reward.claimed.connect(reward_claimed)
		claim_reward_button.pressed.connect(goal_data.reward.claim)


func update_progress_bar() -> void:
	progress_bar.value = goal_data.progress
	progress_bar.max_value = goal_data.total


func activate() -> void:
	if not goal_data.complete:
		modulate.a = 1.0


func deactivate() -> void:
	if not goal_data.complete:
		modulate.a = 0.75


func complete() -> void:
	rewards_container.visible = false
	claim_reward_button.visible = true


func reward_claimed() -> void:
	modulate.a = 0.25
	claim_reward_button.disabled = true
	claim_reward_button.text = "You've claimed this reward"
	
