extends Control

@onready var enemy_queue := $EnemyActionPanel/EnemyActionQueue
@onready var player_queue := $PlayerActionPanel/PlayerActionQueue

func _on_execute_button_button_down() -> void:
	#var rng = RandomNumberGenerator.new()
	#var enemy_move_queue = BattleManager.enemy.move_queues[rng.randi_range(0, BattleManager.enemy.move_queues.size() - 1)]
	#for i in enemy_move_queue.queue:
		#enemy_queue.add_move_segment(i, enemy_move_queue.queue[i])
		#
	#var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	#await tween.tween_property($CanvasLayer/ActionSelect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.6).finished
	#tween = get_tree().create_tween()
	#tween.tween_method(_move_cursor, 0, $CanvasLayer/PlayerActionQueue/CursorMargin.size[0], BattleManager.timeline_length)
	#$CanvasLayer/ActionSelect.visible = false
	#BattleManager.start_execution_phase()
	var rng = RandomNumberGenerator.new()
	var enemy_move_queue = BattleManager.enemy.move_queues[rng.randi_range(0, BattleManager.enemy.move_queues.size() - 1)]
	for move in enemy_move_queue.queue:
		pass
