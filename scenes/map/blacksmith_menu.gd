extends MarginContainer

@onready var upgrade_menu = $HBoxContainer/UpgradeMenu
func _ready() -> void:
	$HBoxContainer/Panel/VBoxContainer/BlacksmithTabs/Upgrade/CenterContainer/VBoxContainer/ItemSlot.item_added.connect(_upgrade_item_added)
	$HBoxContainer/Panel/VBoxContainer/BlacksmithTabs/Upgrade/CenterContainer/VBoxContainer/ItemSlot.item_removed.connect(_upgrade_item_removed)

func _upgrade_item_added(item: Item) -> void:
	upgrade_menu.show()

func _upgrade_item_removed() -> void:
	upgrade_menu.hide()
