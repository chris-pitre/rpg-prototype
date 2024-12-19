class_name BattleActor2D extends Node2D

@export var battle_actor_stats: BattleActorStats:
	set(p_battle_actor_stats):
		battle_actor_stats = p_battle_actor_stats

func _ready() -> void:
	$AnimatedSprite2D.animation = "default"
	if battle_actor_stats.is_player:
		BattleManager.player_animation.connect(_do_animation)
	else:
		BattleManager.enemy_animation.connect(_do_animation)

func _do_animation(animation_name: String, duration: float) -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.speed_scale = 1.0 / duration
	$AnimationPlayer.play("player/"+animation_name)

func _execute_move(move_idx: int) -> void:
	if battle_actor_stats.is_player:
		BattleManager.execute_action(BattleManager.player, BattleManager.enemy, battle_actor_stats.moves[move_idx])
	else:
		BattleManager.execute_action(BattleManager.enemy, BattleManager.player, battle_actor_stats.moves[move_idx])
