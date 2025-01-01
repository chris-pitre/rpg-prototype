class_name ItemWeapon
extends Item

enum {
	FISTS,
	SWORD,
	MACE,
	SPEAR
}

@export_enum("Fists", "Sword", "Mace", "Spear") var weapon_type: int = 0
@export var base_damage: int = 10
@export var stat_block: StatBlock
@export var purchasable_upgrades: Array[WeaponUpgrade]
@export var purchasable_actions: Array[BattleAction]

var upgrades: Array[WeaponUpgrade] = []

func add_upgrade(upgrade: WeaponUpgrade) -> void:
	stat_block = stat_block.add(upgrade.stat_block)
