extends GridContainer

const ITEM_BUTTON = preload("res://scenes/inventory/item_button.tscn")

@export var allow_drop: bool = false

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is ItemDrag and get_child_count() < 36 and allow_drop

func _drop_data(at_position: Vector2, data: Variant) -> void:
	print(data.get_class())
	data = data as ItemDrag
	data.destination = self
	if data.source:
		data.source.queue_free()
	
	var new_item_button = ITEM_BUTTON.instantiate()
	add_child(new_item_button)
	new_item_button.item = data.item
	new_item_button.allow_drag = true
