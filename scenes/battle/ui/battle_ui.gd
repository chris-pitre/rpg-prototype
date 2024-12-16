class_name BattleUI extends Control

@export var queued_move_scene: PackedScene
@onready var queue = $ActionQueue/MarginContainer/HFlowContainer

func _ready() -> void:
	for move_button in $ActionSelect/MarginContainer/VSplitContainer/VBoxContainer.get_children():
		move_button.pressed.connect(_on_move_select_pressed.bind(move_button))
		
func _on_move_select_pressed(move_button: MoveButton) -> void:
	if(BattleManager.filled_duration >= move_button.move_res.duration):
		var queued_move = queued_move_scene.instantiate()
		queued_move.move_res = move_button.move_res
		queued_move.custom_minimum_size = Vector2((move_button.move_res.duration * queue.size[0]) - 5, 0)
		BattleManager.move_added(move_button.move_res)
		queue.add_child(queued_move)
		queued_move.pressed.connect(_on_move_queue_pressed.bind(queued_move))

func _on_move_queue_pressed(move_button: MoveButton) -> void:
	BattleManager.move_removed(move_button.move_res)
	move_button.queue_free()

func _on_execute_button_pressed() -> void:
	var tween = create_tween()
	tween.tween_method(_move_cursor, 0, $ActionQueue/CursorMargin.size[0], 1.0)
	
func _move_cursor(margin: int) -> void:
	$ActionQueue/CursorMargin.add_theme_constant_override("margin_left", margin)
