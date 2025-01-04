class_name StatStatus
extends Status

enum STAT_DAMAGE_TYPES{
	HP,
	POSTURE,
	BOTH
}

signal status_finished(status: StatStatus)

@export_category("Damage Modifiers")
@export_enum("Incoming", "Outgoing", "Both") var stat_direction: int = 0
@export var damage_type: STAT_DAMAGE_TYPES = STAT_DAMAGE_TYPES.HP
@export var multiplier: float = 1.0

@export_category("Status Settings")
@export var duration_timesteps: int = 20
var duration: Variant = null
@export var anim_name: StringName = "<null>"

func decrease_duration(battle_actor_stats: BattleActorStats) -> void:
	if duration == null:
		duration = duration_timesteps
	duration -= 1
	if duration <= 0:
		status_finished.emit(self)
