class_name ItemButton
extends Button

@export var allow_drag: bool = false
@export var item: Item:
	set = _set_item

var on_sale: bool = false:
	set = _set_on_sale

func _set_item(_item: Item) -> void:
	item = _item
	$NameText.text = item.name
	tooltip_text = item.description

func _set_on_sale(_on_sale: bool) -> void:
	on_sale = _on_sale
	if on_sale:
		$PriceText.text = str(item.price)
		$PriceText.visible = true
	else:
		$PriceText.visible = false

func _get_drag_data(at_position: Vector2) -> Variant:
	if allow_drag:
		var drag_preview = self.duplicate()
		set_drag_preview(drag_preview)
		
		var drag_data = ItemDrag.new(self, item, drag_preview)
		
		return drag_data
	return null
