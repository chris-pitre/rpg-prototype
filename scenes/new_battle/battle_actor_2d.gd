class_name BattleActor2D extends Node2D

@export var is_player: bool
var current_move: MoveResource

func _ready() -> void:
	$AnimatedSprite2D.animation = "default"
	if is_player:
		BattleManager.player_animation.connect(_do_animation)
	else:
		BattleManager.enemy_animation.connect(_do_animation)

func _do_animation(animation_name: String, new_move: MoveResource) -> void:
	$AnimationPlayer.stop()
	current_move = new_move
	$AnimationPlayer.play("player/"+animation_name)

func _execute_move(move_name: String) -> void:
	if is_player:
		BattleManager.execute_action(BattleManager.player, BattleManager.enemy, BattleManager.moves[move_name])
	else:
		BattleManager.execute_action(BattleManager.enemy, BattleManager.player, BattleManager.moves[move_name])

func _adjust_speed_scale(current_phase: int) -> void:
	var frames: int
	match current_phase:
		BattleActorStats.PHASE_STATE.WINDUP:
			frames = current_move.windup
		BattleActorStats.PHASE_STATE.ACTIVE:
			frames = current_move.active
		BattleActorStats.PHASE_STATE.RECOVERY:
			frames = current_move.recovery
		_:
			frames = 1
	$AnimationPlayer.speed_scale = (1.0 / BattleManager.time_step) / frames

func _windup_start() -> void:
	_adjust_speed_scale(BattleActorStats.PHASE_STATE.WINDUP)
	
func _active_start() -> void:
	_adjust_speed_scale(BattleActorStats.PHASE_STATE.ACTIVE)

func _recovery_start() -> void:
	_adjust_speed_scale(BattleActorStats.PHASE_STATE.RECOVERY)
