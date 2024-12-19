extends MarginContainer

var text_timeout: SceneTreeTimer

@onready var item_slot = $VBoxContainer/CenterContainer/VBoxContainer/ItemSlot
@onready var sell_info = $VBoxContainer/SellInfo 

func _on_sell_button_pressed() -> void:
	if item_slot.item_button:
		if item_slot.item_button.item.can_be_sold:
			item_slot.item_button.queue_free()
			GameState.gold += item_slot.item_button.item.price
			if text_timeout:
				text_timeout.disconnect("timeout", _on_sell_info_timeout)
			sell_info.text = "Sold for %d gold." % item_slot.item_button.item.price
			text_timeout = get_tree().create_timer(4)
			text_timeout.timeout.connect(func(): sell_info.text = "")
		else:
			if text_timeout:
				text_timeout.disconnect("timeout", _on_sell_info_timeout)
			sell_info.text = "I'm not buying that."
			text_timeout = get_tree().create_timer(4)
			text_timeout.timeout.connect(_on_sell_info_timeout)

func _on_sell_info_timeout() -> void:
	sell_info.text = ""
