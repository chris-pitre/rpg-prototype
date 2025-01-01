extends MarginContainer

@onready var action_button_container = $HBoxContainer/ActionsMenu/ScrollContainer/MarginContainer/ActionButtonContainer
@onready var actions_panel = $HBoxContainer/ActionsMenu

func _action_button_pressed(action: BattleAction) -> void:
	if GameState.gold >= action.price:
		GameState.gold -= action.price
		GameState.give_action(action)

func _on_weapon_slot_item_added(item: Item) -> void:
	actions_panel.show()
	item = item as ItemWeapon
	for action in item.purchasable_actions:
		if not action.name in GameState.learned_actions:
			var new_button = Button.new()
			action_button_container.add_child(new_button)
			new_button.pressed.connect(_action_button_pressed.bind(action))

func _on_weapon_slot_item_removed(item: Item) -> void:
	actions_panel.hide()
	for child in action_button_container.get_children():
		remove_child(child)
		child.queue_free()
