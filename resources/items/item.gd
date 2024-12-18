class_name Item
extends Resource

enum TYPE {
	MISC,
	WEAPON,
	ACCESSORY,
	MATERIAL,
	CONSUMABLE,
}

@export var name: String = "ItemName"
@export_multiline var description: String = "Description"
@export var texture: Texture2D
@export var price: int = 0
@export var can_be_sold: bool = true
@export var type: TYPE = Item.TYPE.MISC
@export var weapon_attributes: WeaponAttributes
