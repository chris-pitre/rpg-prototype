extends MarginContainer

const ITEM_BUTTON = preload("res://scenes/inventory/item_button.tscn")

@export var items_for_sale: Array[Item]

var selected_item_button: ItemButton
var text_timeout: SceneTreeTimer

@onready var buy_grid = $VBoxContainer/ItemContainer
@onready var buy_button = $VBoxContainer/HBoxContainer/BuyButton
@onready var buy_info = $VBoxContainer/BuyInfo

func _ready() -> void:
	for item in items_for_sale:
		var new_item_button = ITEM_BUTTON.instantiate()
		buy_grid.add_child(new_item_button)
		new_item_button.item = item
		new_item_button.focus_entered.connect(_item_focused.bind(new_item_button))
	for child in buy_grid.get_children():
		if child is ItemButton:
			child.on_sale = true

func _item_focused(item_button: ItemButton) -> void:
	if item_button in buy_grid.get_children():
		buy_button.show()
		selected_item_button = item_button

func _on_buy_button_pressed() -> void:
	if GameState.gold >= selected_item_button.item.price:
		if GameState.give_item(selected_item_button.item):
			GameState.gold -= selected_item_button.item.price
	else:
		if text_timeout:
			text_timeout.disconnect("timeout", _on_buy_info_timeout)
		buy_info.text = "You don't have enough money."
		
		text_timeout = get_tree().create_timer(4)
		text_timeout.timeout.connect(_on_buy_info_timeout)


func _on_buy_info_timeout() -> void:
	buy_info.text = ""
