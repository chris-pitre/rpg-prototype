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
	else:
		BattleManager.enemy_hp_updated.connect(_update_hp)
		BattleManager.enemy_posture_updated.connect(_update_posture)
		BattleManager.enemy_start_move.connect(_start_move)

func show_frame(frame_name: String) -> void:
	anim_sprite.animation = frame_name

func _update_hp(new_hp: int) -> void:
	if new_hp < health_bar.value:
		damage_anim(5)
		show_blood()
	health_bar.value = new_hp
	health_label.text = str(new_hp)
	
func _update_posture(new_posture: int) -> void:
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
	if not current_move.windup_anim_name.is_empty():
		anim_sprite.animation = current_move.windup_anim_name
	while frames_remaining > 0:
		await BattleManager.next_execution_timestep
		frames_remaining -= 1
	start_active()

func start_active():
	var frames_remaining = current_move.active
	if not current_move.active_anim_name.is_empty():
		anim_sprite.animation = current_move.active_anim_name
	if is_player:
		BattleManager.execute_action(BattleManager.player, BattleManager.enemy, current_move)
	else:
		BattleManager.execute_action(BattleManager.enemy, BattleManager.player, current_move)
	while frames_remaining > 0:
		await BattleManager.next_execution_timestep
		frames_remaining -= 1
	start_recovery()
	
func start_recovery():
	var frames_remaining = current_move.recovery
	if not current_move.recovery_anim_name.is_empty():
		anim_sprite.animation = current_move.recovery_anim_name
	while frames_remaining > 0:
		await BattleManager.next_execution_timestep
		frames_remaining -= 1
	if current_move.followup_attack != null:
		current_move = current_move.followup_attack
		start_windup()
	else:
		anim_sprite.animation = current_move.return_anim_name
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
