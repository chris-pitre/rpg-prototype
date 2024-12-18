class_name Battle extends Node

@export var queued_move_scene: PackedScene
@onready var queue = $CanvasLayer/PlayerActionQueue/MarginContainer/MoveTimeline
@onready var move_drag_and_drop_scene = preload("res://scenes/battle/move_drop.tscn")

func _ready() -> void:
	BattleManager.battle_started.connect(_start_battle)
	BattleManager.planning_phase_started.connect(_start_planning)
	
func _start_battle() -> void:
	$CanvasLayer/BattlePopup.visible = true
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property($CanvasLayer/BattlePopup, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.6)
	await tween.tween_property($CanvasLayer/BattlePopup, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.6).set_delay(1.0).finished
	$CanvasLayer/BattlePopup.visible = false
	_get_player_moves()
	BattleManager.planning_phase_started.emit()

func _start_planning() -> void:
	$CanvasLayer/ActionSelect.visible = true
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property($CanvasLayer/ActionSelect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.6)

func _on_execute_button_pressed() -> void:
	var tween = create_tween()
	tween.tween_method(_move_cursor, 0, $CanvasLayer/PlayerActionQueue/CursorMargin.size[0], BattleManager.timeline_length)
	BattleManager.execute_queue()
	
func _move_cursor(margin: int) -> void:
	$CanvasLayer/PlayerActionQueue/CursorMargin.add_theme_constant_override("margin_left", margin)
	
func _get_player_moves() -> void:
	for move in BattleManager.player.moves:
		var move_drag_and_drop = move_drag_and_drop_scene.instantiate()
		move_drag_and_drop.move_resource = move
		$CanvasLayer/ActionSelect/MarginContainer/VSplitContainer/VBoxContainer.add_child(move_drag_and_drop)
