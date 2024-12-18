extends TextureRect

signal item_added()
signal item_removed()

const ITEM_BUTTON = preload("res://scenes/inventory/item_button.tscn")

var item_button: ItemButton

@export var require_type: bool = false
@export var type: Item.TYPE = Item.TYPE.MISC

@onready var center_container = $SellItemContainer

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var is_dragged_item = data is ItemDrag
	var has_space = center_container.get_child_count() == 0
	var correct_type = (require_type and data.item.type == type) or not require_type
	
	return is_dragged_item and has_space and correct_type

func _drop_data(at_position: Vector2, data: Variant) -> void:
	data = data as ItemDrag
	data.destination = self
	if data.source:
		data.source.queue_free()
	
	var new_item_button = ITEM_BUTTON.instantiate()
	center_container.add_child(new_item_button)
	new_item_button.item = data.item
	new_item_button.allow_drag = true
	item_button = new_item_button
	item_button.tree_exiting.connect(item_removed.emit)
	item_added.emit(data.item)
