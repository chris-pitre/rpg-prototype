extends Control

func use_item_button(item_button: ItemButton) -> void:
	if item_button.item.type == Item.CONSUMABLE:
		item_button.item.use()

func destroy_item_button(item_button: ItemButton) -> void:
	pass

func _on_mouse_exited() -> void:
	queue_free()
