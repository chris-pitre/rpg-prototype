extends VBoxContainer

@export var is_player: bool = false

@onready var guard_label := $GuardLabel
@onready var stun_label := $StunLabel
@onready var status_label_scene := preload("res://scenes/new_battle/stat_status_label.tscn")

var stat_status_dict: Dictionary = {}
var actor: BattleActorStats

func _ready() -> void:
	BattleManager.battle_started.connect(_battle_started)
	BattleManager.next_execution_timestep.connect(_update_statuses)
	if is_player:
		BattleManager.player_guard_updated.connect(_guard_updated)
		BattleManager.player_status_added.connect(_add_status)
	else:
		BattleManager.enemy_guard_updated.connect(_guard_updated)
		BattleManager.enemy_status_added.connect(_add_status)

func _battle_started() -> void:
	if is_player:
		actor = BattleManager.player
	else:
		actor = BattleManager.enemy
		
func _guard_updated() -> void:
	if actor.current_guard != GuardStatus.GUARD.NONE:
		match actor.current_guard:
			GuardStatus.GUARD.HIGH_GUARD:
				guard_label.text = "High Guard"
			GuardStatus.GUARD.MIDDLE_GUARD:
				guard_label.text = "Middle Guard"
			GuardStatus.GUARD.LOW_GUARD:
				guard_label.text = "Low Guard"
		guard_label.show()
	else:
		guard_label.hide()

func _add_status(status: StatStatus) -> void:
	var status_label = status_label_scene.instantiate()
	status_label.status_name = status.name
	status_label.status_value = status.duration_timesteps
	add_child(status_label)

func _update_statuses() -> void:
	if actor.stun != null:
		stun_label.text = "Stunned %d" % [actor.stun.stun]
		stun_label.show()
	else:
		stun_label.hide()
	
	for label in get_children():
		if label is StatStatusLabel:
			label.update_value()
