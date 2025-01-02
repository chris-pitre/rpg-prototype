class_name BattleActor2D extends Node2D

@export var is_player: bool

@onready var anim_sprite := $AnimatedSprite2D
@onready var health_bar := $HealthBar
@onready var health_label := $HealthBar/HealthLabel
@onready var posture_bar := $PostureBar
@onready var posture_label := $PostureBar/PostureLabel

var current_move: MoveResource

func _ready() -> void:
	anim_sprite.animation = "default"
	if is_player:
		BattleManager.player_hp_updated.connect(_update_hp)
		BattleManager.player_posture_updated.connect(_update_posture)
		BattleManager.player_start_move.connect(_start_move)
	else:
		BattleManager.enemy_hp_updated.connect(_update_hp)
		BattleManager.enemy_posture_updated.connect(_update_posture)
		BattleManager.enemy_start_move.connect(_start_move)

func show_frame(frame_name: String) -> void:
	anim_sprite.animation = frame_name

func _update_hp(new_hp: int) -> void:
	health_bar.value = new_hp
	health_label.text = str(new_hp)
	
func _update_posture(new_posture: int) -> void:
	posture_bar.value = new_posture
	posture_label.text = str(new_posture)

func _start_move(move: MoveResource) -> void:
	current_move = move
	start_windup()

func start_windup():
	var frames_remaining = current_move.windup
	anim_sprite.animation = current_move.windup_anim_name
	if is_player:
		BattleManager.player.current_phase_state = BattleActorStats.PHASE_STATE.WINDUP
	else:
		BattleManager.enemy.current_phase_state = BattleActorStats.PHASE_STATE.WINDUP
	while frames_remaining > 0:
		await BattleManager.next_execution_timestep
		frames_remaining -= 1
	start_active()

func start_active():
	var frames_remaining = current_move.active
	anim_sprite.animation = current_move.active_anim_name
	if is_player:
		BattleManager.player.current_phase_state = BattleActorStats.PHASE_STATE.ACTIVE
		BattleManager.execute_action(BattleManager.player, BattleManager.enemy, current_move)
	else:
		BattleManager.enemy.current_phase_state = BattleActorStats.PHASE_STATE.ACTIVE
		BattleManager.execute_action(BattleManager.enemy, BattleManager.player, current_move)
	while frames_remaining > 0:
		await BattleManager.next_execution_timestep
		frames_remaining -= 1
	start_recovery()
	
func start_recovery():
	var frames_remaining = current_move.recovery
	anim_sprite.animation = current_move.recovery_anim_name
	if is_player:
		BattleManager.player.current_phase_state = BattleActorStats.PHASE_STATE.RECOVERY
	else:
		BattleManager.enemy.current_phase_state = BattleActorStats.PHASE_STATE.RECOVERY
	while frames_remaining > 0:
		await BattleManager.next_execution_timestep
		frames_remaining -= 1
	if current_move.followup_attack != null:
		current_move = current_move.followup_attack
		start_windup()
	else:
		current_move = null
		anim_sprite.animation = "default"
		if is_player:
			BattleManager.player.current_phase_state = BattleActorStats.PHASE_STATE.BLOCKING
		else:
			BattleManager.enemy.current_phase_state = BattleActorStats.PHASE_STATE.BLOCKING
