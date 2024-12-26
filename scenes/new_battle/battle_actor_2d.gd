class_name BattleActor2D extends Node2D

@export var is_player: bool

func _ready() -> void:
	$AnimatedSprite2D.animation = "default"
	if is_player:
		BattleManager.player_animation.connect(_do_animation)
	else:
		BattleManager.enemy_animation.connect(_do_animation)

func _do_animation(animation_name: String, duration: float) -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.speed_scale = (1.0 / BattleManager.time_step) / duration
	$AnimationPlayer.play("player/"+animation_name)

func _execute_move(move_name: String) -> void:
	if is_player:
		BattleManager.execute_action(BattleManager.player, BattleManager.enemy, BattleManager.moves[move_name])
	else:
		BattleManager.execute_action(BattleManager.enemy, BattleManager.player, BattleManager.moves[move_name])
