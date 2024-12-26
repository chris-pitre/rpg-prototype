extends Control

@onready var enemy_queue := $CanvasLayer/EnemyActionPanel/EnemyActionQueue
@onready var player_queue := $CanvasLayer/PlayerActionPanel/PlayerActionQueue
@onready var action_block := preload("res://scenes/new_battle/action_block.tscn")

func _ready() -> void:
	BattleManager.start_battle.connect(_start_battle)
	
func _start_battle(encounter: Encounter) -> void:
	visible = true

func _on_execute_button_button_down() -> void:
	var rng = RandomNumberGenerator.new()
	var enemy_move_queue = BattleManager.enemy.move_queues[rng.randi_range(0, BattleManager.enemy.move_queues.size() - 1)]
	var total_length = 0
	for move in enemy_move_queue.queue:
		var move_pos = move + total_length
		var enemy_action_block = action_block.instantiate()
		enemy_action_block.action = enemy_move_queue.queue[move]
		enemy_queue.add_action_block(move_pos - total_length, move_pos, enemy_action_block)
		total_length += enemy_move_queue.queue[move].length
	BattleManager.start_execution_phase()
