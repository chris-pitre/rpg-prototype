class_name BattleUI extends Control

@export var queued_move_scene: PackedScene
@onready var queue = $ActionQueue/MarginContainer/MoveTimeline

func _on_execute_button_pressed() -> void:
	var tween = create_tween()
	tween.tween_method(_move_cursor, 0, $ActionQueue/CursorMargin.size[0], 1.0)
	
func _move_cursor(margin: int) -> void:
	$ActionQueue/CursorMargin.add_theme_constant_override("margin_left", margin)
