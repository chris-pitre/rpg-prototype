extends MarginContainer

@onready var health_bar = $Panel/VBoxContainer/MarginContainer/VBoxContainer/Healthbar
@onready var health_label = $Panel/VBoxContainer/MarginContainer/VBoxContainer/Healthbar/Label
@onready var equip_slot_container: HBoxContainer = $Panel/VBoxContainer/MarginContainer/VBoxContainer/EquipSlotContainer


func _ready() -> void:
	GameState.health_changed.connect(_health_changed)
	
	for slot: ItemSlot in equip_slot_container.get_children():
		slot.extra_condition = slot_allowed_item

func _health_changed(amt: int) -> void:
	health_bar.value = amt / GameState.max_health
	health_label.text = str(amt) + " hp"

func slot_allowed_item(item: Item) -> bool:
	return true
