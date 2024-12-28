class_name ItemWeapon
extends Item

@export_enum("Fists", "Sword", "Mace", "Spear") var weapon_type: int = 0
@export var damage: int = 1
@export var total_damage_offset: int
@export var total_posture_damage_offset: int
@export var total_windup_time_offset: int = 0
@export var total_active_time_offset: int = 0
@export var total_recovery_time_offset: int = 0

var upgrades: Array[WeaponUpgrade] = []

func add_upgrade(upgrade: WeaponUpgrade) -> void:
	total_damage_offset += upgrade.damage_offset
	total_posture_damage_offset += upgrade.posture_damage_offset
	total_windup_time_offset += upgrade.windup_time_offset
	total_active_time_offset += upgrade.active_time_offset
	total_recovery_time_offset += upgrade.recovery_time_offset
