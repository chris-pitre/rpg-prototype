extends MarginContainer

@onready var health_bar = $Panel/VBoxContainer/MarginContainer/VBoxContainer/Healthbar
@onready var health_label = $Panel/VBoxContainer/MarginContainer/VBoxContainer/Healthbar/Label
@onready var equip_slot_container: HBoxContainer = $Panel/VBoxContainer/MarginContainer/VBoxContainer/EquipSlotContainer

func _ready() -> void:
	GameState.health_changed.connect(_health_changed)
	GameState.stat_block_changed.connect(_stat_block_changed)
	
	for slot: ItemSlot in equip_slot_container.get_children():
		slot.extra_condition = slot_allowed_item
		slot.item_added.connect(_slot_item_added)
		slot.item_removed.connect(_slot_item_removed)

func _health_changed(amt: int) -> void:
	health_bar.value = amt / GameState.max_health
	health_label.text = str(amt) + " hp"

func slot_allowed_item(item: Item) -> bool:
	return true

func _slot_item_removed(item: Item) -> void:
	if item is ItemWeapon:
		GameState.equip_weapon(null)
	
	GameState.stat_block = GameState.stat_block.sub(item.stat_block)

func _slot_item_added(item: Item) -> void:
	if item is ItemWeapon:
		GameState.equip_weapon(item)
	
	GameState.stat_block = GameState.stat_block.add(item.stat_block)

func _stat_block_changed(stat_block: StatBlock) -> void:
	$Panel/VBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/StatLabelContainer/DamageOffset.text = "damageoffset: %+d" % stat_block.damage_offset
	$Panel/VBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/StatLabelContainer/PostureDamageOffset.text = "posturedamageoffset: %+d" % stat_block.posture_damage_offset
	$Panel/VBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/StatLabelContainer/DamageDefense.text = "damagedefense: %+d" % stat_block.damage_defense
	$Panel/VBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/StatLabelContainer/PostureDefense.text = "posturedefense: %+d" % stat_block.posture_defense
	$Panel/VBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/StatLabelContainer/WindupOffset.text = "windupoffset: %+d" % stat_block.windup_time_offset
	$Panel/VBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/StatLabelContainer/ActiveOffset.text = "activeoffset: %+d" % stat_block.active_time_offset
	$Panel/VBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/StatLabelContainer/RecoveryOffset.text = "recoveryoffset: %+d" % stat_block.recovery_time_offset
	$Panel/VBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/StatLabelContainer/Power.text = "power: %+d" % stat_block.stat_power_offset
	$Panel/VBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/StatLabelContainer/Agility.text = "agility: %+d" % stat_block.stat_agility_offset
	$Panel/VBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/StatLabelContainer/Speech.text = "speech: %+d" % stat_block.stat_speech_offset
	$Panel/VBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/StatLabelContainer/Piety.text = "piety: %+d" % stat_block.stat_piety_offset
