extends HBoxContainer

@onready var ACTIVE_ACTION_BLOCK = preload("res://scenes/new_battle/active_action_block.tscn")

var current_timestep: int = 0

func _ready() -> void:
	for i in range(BattleManager.max_timestep):
		var new_empty = ACTIVE_ACTION_BLOCK.instantiate()
		new_empty.modulate.a = 0.0
		add_child(new_empty)
	BattleManager.next_execution_timestep.connect(_do_timestep)
	BattleManager.battle_ended.connect(_battle_ended)

func _battle_ended(encounter: Encounter, player_lost: bool) -> void:
	current_timestep = 0
	for child in get_children():
		child.modulate.a = 0.0

func _do_timestep() -> void:
	if current_timestep > 0:
		get_child(current_timestep - 1).modulate.a = 0.0
	get_child(current_timestep).modulate.a = 1.0
	if current_timestep >= BattleManager.max_timestep - 1:
		get_child(current_timestep).modulate.a = 0.0
		current_timestep = 0
	else:
		current_timestep += 1
