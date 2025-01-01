class_name Item
extends Resource

enum {
	WEAPON = 1,
	MATERIAL = 2,
	VALUABLE = 4,
	CONSUMABLE = 8,
	ACCESSORY = 16,
}

@export var name: String = "ItemName"
@export_multiline var description: String = "Description"
@export var texture: Texture2D
@export var price: int = 0
@export var can_be_sold: bool = true
@export_flags("Weapon", "Material", "Valuable", "Consumable", "Accessory") var type: int = 0
