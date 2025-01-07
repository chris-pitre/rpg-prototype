extends MarginContainer

@onready var action_button_container = $HBoxContainer/ActionsMenu/ScrollContainer/MarginContainer/ActionButtonContainer
@onready var actions_panel = $HBoxContainer/ActionsMenu

func _move_button_pressed(button, weapon_type: int, move: MoveResource) -> void:
	if GameState.gold >= move.price:
		GameState.gold -= move.price
		GameState.learn_move(weapon_type, move)
		button.queue_free()

func _on_weapon_slot_item_added(item: Item) -> void:
	actions_panel.show()
	item = item as ItemWeapon
	for move in item.purchasable_moves:
		if not move.name in GameState.learned_actions:
			var new_button = Button.new()
			new_button.text = move.name
			action_button_container.add_child(new_button)
			new_button.pressed.connect(_move_button_pressed.bind(new_button, item.weapon_type, move))

func _on_weapon_slot_item_removed(item: Item) -> void:
	actions_panel.hide()
	for child in action_button_container.get_children():
		remove_child(child)
		child.queue_free()
