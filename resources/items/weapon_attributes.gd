class_name WeaponAttributes
extends Resource

enum TYPE {
	FISTS,
	SWORD,
	MACE,
	SPEAR,
}

@export var type: TYPE = TYPE.SWORD
@export var upgrades: Array[String]
@export var posture_damage_multiplier: float
@export var windup_time_amount_offset: float = 0.0
@export var active_time_amount_offset: float = 0.0
@export var recovery_time_amount_offset: float = 0.0
