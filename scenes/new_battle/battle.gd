extends Control

@onready var enemy_queue := $CanvasLayer/EnemyActionPanel/EnemyActionQueue
@onready var player_queue := $CanvasLayer/PlayerActionPanel/PlayerActionQueue
@onready var action_palette_margin := $CanvasLayer/RightMargin
@onready var action_palette := $CanvasLayer/RightMargin/ActionPanel/MarginContainer/VBoxContainer/VBoxContainer
@onready var action_block := preload("res://scenes/new_battle/action_block.tscn")
@onready var camera = $Camera2D

func _ready() -> void:
	BattleManager.start_battle.connect(_start_battle)
	BattleManager.planning_phase_started.connect(_show_action_palette)
	BattleManager.battle_ended.connect(_end_battle)

func _start_battle(encounter: Encounter) -> void:
	visible = true
	BattleManager.battle_started.emit()
	
func _end_battle(encounter: Encounter, is_player: bool) -> void:
	BattleManager.queued_player_moves = {}
	player_queue.reset_blocks()
	BattleManager.queued_enemy_moves = {}
	enemy_queue.reset_blocks()

func _get_player_moves() -> void:
	BattleManager.queued_player_moves = {}
	player_queue.reset_blocks()
	for child in action_palette.get_children():
		action_palette.remove_child(child)
		child.queue_free()
	for move: String in BattleManager.player.moves:
		var move_resource = BattleManager.moves[move]
		if BattleManager.player.current_guard == move_resource.require_guard or move_resource.require_guard == GuardStatus.GUARD.NONE:
			var new_action_block = action_block.instantiate()
			new_action_block.action = move_resource
			action_palette.add_child(new_action_block)

func _on_execute_button_button_down() -> void:
	for child in enemy_queue.get_children():
		if child is ActionBlock:
			child.is_obscured = false
	action_palette_margin.hide()
	BattleManager.start_execution_phase()

func _show_action_palette() -> void:
	_get_player_moves()
	_get_enemy_moves()
	action_palette_margin.show()

func _get_enemy_moves() -> void:
	BattleManager.queued_enemy_moves = {}
	enemy_queue.reset_blocks()
	await get_tree().process_frame
	var enemy_move_queue = BattleManager.enemy.move_queues[GameState.rng.randi_range(0, BattleManager.enemy.move_queues.size() - 1)]
	var total_length = 0
	for move in enemy_move_queue.queue:
		var move_pos = move + total_length
		var enemy_action_block = action_block.instantiate()
		enemy_action_block.action = enemy_move_queue.queue[move]
		enemy_queue.add_action_block(move_pos - total_length, move_pos, enemy_action_block, true)
		total_length += enemy_move_queue.queue[move].length - 1
