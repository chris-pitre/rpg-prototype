class_name Battle extends Node

@export var queued_move_scene: PackedScene
@onready var enemy_queue = $CanvasLayer/EnemyActionQueue
@onready var player_queue = $CanvasLayer/PlayerActionQueue
@onready var enemy_hp_label = $CanvasLayer/EnemyHP/Label
@onready var player_hp_label = $CanvasLayer/PlayerHP/Label
@onready var move_drag_and_drop_scene = preload("res://scenes/battle/move_drop.tscn")

func _ready() -> void:
	BattleManager.start_battle.connect(_start_battle)
	BattleManager.planning_phase_started.connect(_start_planning)
	BattleManager.player_stats_updated.connect(_adjust_player_hp)
	BattleManager.enemy_stats_updated.connect(_adjust_enemy_hp)
	BattleManager.battle_ended.connect(_end_battle)
	
func _start_battle(encounter: Encounter) -> void:
	$CanvasLayer/BattlePopup.visible = true
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property($CanvasLayer/BattlePopup, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.6)
	await tween.tween_property($CanvasLayer/BattlePopup, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.6).set_delay(1.0).finished
	$CanvasLayer/BattlePopup.visible = false
	_get_player_moves()
	BattleManager.battle_started.emit()

func _start_planning() -> void:
	player_queue.clear_queue()
	enemy_queue.clear_queue()
	$CanvasLayer/ActionSelect.visible = true
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property($CanvasLayer/ActionSelect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.6)

func _on_execute_button_pressed() -> void:
	var rng = RandomNumberGenerator.new()
	var enemy_move_queue = BattleManager.enemy.move_queues[rng.randi_range(0, BattleManager.enemy.move_queues.size() - 1)]
	for i in enemy_move_queue.queue:
		enemy_queue.add_move_segment(i, enemy_move_queue.queue[i])
		
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	await tween.tween_property($CanvasLayer/ActionSelect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.6).finished
	tween = get_tree().create_tween()
	tween.tween_method(_move_cursor, 0, $CanvasLayer/PlayerActionQueue/CursorMargin.size[0], BattleManager.timeline_length)
	$CanvasLayer/ActionSelect.visible = false
	BattleManager.start_execution_phase()
	
func _move_cursor(margin: int) -> void:
	$CanvasLayer/PlayerActionQueue/CursorMargin.add_theme_constant_override("margin_left", margin)
	
func _get_player_moves() -> void:
	for move in BattleManager.player.moves:
		var move_drag_and_drop = move_drag_and_drop_scene.instantiate()
		move_drag_and_drop.move_resource = move
		$CanvasLayer/ActionSelect/MarginContainer/VSplitContainer/VBoxContainer.add_child(move_drag_and_drop)

func _clear_player_moves() -> void:
	for move in $CanvasLayer/ActionSelect/MarginContainer/VSplitContainer/VBoxContainer.get_children():
		move.queue_free()

func _end_battle(encounter: Encounter, player_lost: bool) -> void:
	_clear_player_moves()
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	await tween.tween_property($CanvasLayer/ActionSelect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.6).finished
	$CanvasLayer/ActionSelect.visible = false 

func _adjust_player_hp(new_value: int) -> void:
	player_hp_label.text = str(new_value)

func _adjust_enemy_hp(new_value: int) -> void:
	enemy_hp_label.text  = str(new_value)
