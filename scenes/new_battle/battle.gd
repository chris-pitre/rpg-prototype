extends Control

const CLASH_EFFECT = preload("res://scenes/effects/clash_effect.tscn")
const BATTLE_ACTOR_2D = preload("res://scenes/new_battle/battle_actor_2d.tscn")
const ENEMY_ACTOR_2D = preload("res://scenes/new_battle/enemy_actor_2d.tscn")

var player_actor_2d
var enemy_actor_2d

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
	BattleManager.clashed.connect(_on_clashed)

func _start_battle(encounter: Encounter) -> void:
	visible = true
	BattleManager.battle_started.emit()
	if player_actor_2d:
		player_actor_2d.queue_free()
	if enemy_actor_2d:
		enemy_actor_2d.queue_free()
	player_actor_2d = BATTLE_ACTOR_2D.instantiate()
	$PlayerAnchor.add_child(player_actor_2d)
	enemy_actor_2d = ENEMY_ACTOR_2D.instantiate()
	$EnemyAnchor.add_child(enemy_actor_2d)
	
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
		var move_resource: MoveResource = BattleManager.moves[move]
		var move_modified = GameState.get_modified_move(move_resource)
		
		var new_action_block = action_block.instantiate()
		if BattleManager.player.current_guard != move_resource.require_guard:
			new_action_block.is_usable = false
		new_action_block.action = move_modified
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
		enemy_action_block.action = enemy_move_queue.queue[move].duplicate()
		enemy_action_block.action.opponent_damage = BattleManager.enemy.enemy_base_damage
		enemy_queue.add_action_block(move_pos - total_length, move_pos, enemy_action_block, true)
		total_length += enemy_move_queue.queue[move].length - 1

func _on_clashed() -> void:
	var new_effect = CLASH_EFFECT.instantiate()
	$ClashPosition.add_child(new_effect)
