class_name BattleActor2D extends Node2D

const BLOOD_SPLASH = preload("res://scenes/effects/blood_splash.tscn")
const BLOCK_PARTICLES = preload("res://scenes/effects/block_particles.tscn")

@export var is_player: bool

@onready var anim_sprite := $AnimatedSprite2D
@onready var health_bar := $HealthBar
@onready var health_label := $HealthBar/HealthLabel
@onready var posture_bar := $PostureBar
@onready var posture_label := $PostureBar/PostureLabel

var shake_tween: Tween
var current_move: MoveResource

func _ready() -> void:
	anim_sprite.animation = "default"
	if is_player:
		BattleManager.player_hp_updated.connect(_update_hp)
		BattleManager.player_posture_updated.connect(_update_posture)
		BattleManager.player_start_move.connect(_start_move)
		BattleManager.player_guard_updated.connect(_update_guard)
	else:
		BattleManager.enemy_hp_updated.connect(_update_hp)
		BattleManager.enemy_posture_updated.connect(_update_posture)
		BattleManager.enemy_start_move.connect(_start_move)

func show_frame(frame_name: String) -> void:
	anim_sprite.animation = frame_name

func _update_hp(new_hp: int) -> void:
	var diff = new_hp - health_bar.value
	var shake_amt = clamp(abs(diff), 1, 5)
	
	if new_hp < health_bar.value:
		damage_anim(shake_amt)
		show_blood()
	health_bar.value = new_hp
	health_label.text = str(new_hp)
	
func _update_posture(new_posture: int) -> void:
	var diff = new_posture - posture_bar.value
	
	if new_posture < posture_bar.value:
		damage_anim(1)
		show_block()
	posture_bar.value = new_posture
	posture_label.text = str(new_posture)

func _start_move(move: MoveResource) -> void:
	current_move = move
	start_windup()

func start_windup():
	var frames_remaining = current_move.windup
	if is_player:
		BattleManager.player.current_phase_state = BattleActorStats.PHASE_STATE.WINDUP
		if current_move.guard_switching:
			BattleManager.guard_switching_started.emit()
	else:
		BattleManager.enemy.current_phase_state = BattleActorStats.PHASE_STATE.WINDUP
	if not current_move.windup_anim_name.is_empty():
		anim_sprite.animation = current_move.windup_anim_name
	while frames_remaining > 0:
		await BattleManager.next_execution_timestep
		frames_remaining -= 1
		if not BattleManager.battle_active:
			anim_sprite.animation = "default"
			return
	start_active()

func start_active():
	var frames_remaining = current_move.active
	if not current_move.active_anim_name.is_empty():
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
		if not BattleManager.battle_active:
			anim_sprite.animation = "default"
			return
	start_recovery()
	
func start_recovery():
	var frames_remaining = current_move.recovery
	if is_player:
		BattleManager.player.current_phase_state = BattleActorStats.PHASE_STATE.RECOVERY
	else:
		BattleManager.enemy.current_phase_state = BattleActorStats.PHASE_STATE.RECOVERY
	if not current_move.recovery_anim_name.is_empty():
		anim_sprite.animation = current_move.recovery_anim_name
	while frames_remaining > 0:
		await BattleManager.next_execution_timestep
		frames_remaining -= 1
		if not BattleManager.battle_active:
			anim_sprite.animation = "default"
			return
	if current_move == null:
		anim_sprite.animation = "default"
		return
	elif current_move.followup_attack != null:
		current_move = current_move.followup_attack
		start_windup()
	else:
		anim_sprite.animation = current_move.return_anim_name
		if is_player:
			BattleManager.player.current_phase_state = BattleActorStats.PHASE_STATE.BLOCKING
			if current_move.guard_switching:
				BattleManager.guard_switching_ended.emit()
		else:
			BattleManager.enemy.current_phase_state = BattleActorStats.PHASE_STATE.BLOCKING
		current_move = null

func damage_anim(amt: float) -> void:
	if shake_tween:
		shake_tween.stop()

	shake_tween = get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	position.x = 10 * amt
	shake_tween.tween_property(self, "position", Vector2.ZERO, 0.3)

func show_blood() -> void:
	var new_effect = BLOOD_SPLASH.instantiate()
	add_child(new_effect)

func show_block() -> void:
	var new_effect = BLOCK_PARTICLES.instantiate()
	add_child(new_effect)

func _update_guard(guard_status: GuardStatus.GUARD) -> void:
	if not current_move.guard_switching:
		return
	
	match guard_status:
		GuardStatus.GUARD.NONE:
			show_frame("default")
		GuardStatus.GUARD.HIGH_GUARD:
			show_frame("highguard")
		GuardStatus.GUARD.MIDDLE_GUARD:
			show_frame("swordblock")
		GuardStatus.GUARD.LOW_GUARD:
			show_frame("tailguard")
