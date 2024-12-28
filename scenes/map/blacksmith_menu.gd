extends MarginContainer

const UPGRADES_DIR = "res://resources/upgrades/"

var upgrades: Array[WeaponUpgrade]
var current_weapon: ItemWeapon

@onready var upgrade_menu = $HBoxContainer/UpgradeMenu
@onready var upgrade_item_slot = $HBoxContainer/Panel/VBoxContainer/BlacksmithTabs/Upgrade/CenterContainer/VBoxContainer/ItemSlot
@onready var upgrade_button_container = $HBoxContainer/UpgradeMenu/ScrollContainer/MarginContainer/UpgradeButtonContainer

func _ready() -> void:
	upgrade_item_slot.item_added.connect(_upgrade_item_added)
	upgrade_item_slot.item_removed.connect(_upgrade_item_removed)
	
	var dir = DirAccess.open(UPGRADES_DIR)
	if dir:
		for file_name in dir.get_files():
			file_name = file_name.trim_suffix(".remap")
			var upgrade = ResourceLoader.load(UPGRADES_DIR + "/" + file_name)
			if upgrade is WeaponUpgrade:
				upgrades.append(upgrade)

func _upgrade_item_added(item: ItemWeapon) -> void:
	upgrade_menu.show()
	current_weapon = item
	for upgrade in upgrades:
		if not current_weapon.upgrades.has(upgrade):
			var new_upgrade_button = Button.new()
			upgrade_button_container.add_child(new_upgrade_button)
			new_upgrade_button.text = upgrade.name
			new_upgrade_button.tooltip_text = upgrade.description
			new_upgrade_button.pressed.connect(_upgrade_button_pressed.bind(new_upgrade_button, upgrade))


func _upgrade_item_removed() -> void:
	for child in upgrade_button_container.get_children():
		remove_child(child)
		child.queue_free()
	current_weapon = null
	upgrade_menu.hide()


func _upgrade_button_pressed(upgrade_button: Button, upgrade: WeaponUpgrade) -> void:
	if GameState.gold >= upgrade.price:
		upgrade_button.queue_free()
		current_weapon.add_upgrade(upgrade)
