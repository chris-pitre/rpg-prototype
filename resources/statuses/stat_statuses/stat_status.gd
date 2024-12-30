class_name StatStatus
extends Status

enum STAT_DAMAGE_TYPES{
	HP,
	POSTURE,
	BOTH
}

@export_category("Damage Modifiers")
@export_enum("Incoming", "Outgoing", "Both") var stat_direction: int = 0
@export var damage_type: STAT_DAMAGE_TYPES = STAT_DAMAGE_TYPES.HP
@export var multiplier: float = 1.0

func get_multiplier() -> float:
	return multiplier
