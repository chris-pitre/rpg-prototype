class_name Item
extends Resource

@export var name: String = "ItemName"
@export_multiline var description: String = "Description"
@export var texture: Texture2D
@export var price: int = 0
@export var can_be_sold: bool = true
@export_flags("Weapon", "Material", "Valuable", "Consumable") var type: int = 0
@export var weapon_attributes: WeaponAttributes
