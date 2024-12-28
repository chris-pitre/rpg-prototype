extends MarginContainer

@export var actions_to_buy: Array[BattleAction]

@onready var action_button_container = $Panel/VBoxContainer/ScrollContainer/VBoxContainer

func _ready() -> void:
	for action in actions_to_buy:
		var new_button = Button.new()
		action_button_container.add_child(new_button)
		new_button.pressed.connect(_action_button_pressed.bind(action))

func _action_button_pressed(action: BattleAction) -> void:
	if GameState.gold >= action.price:
		GameState.gold -= action.price
		GameState.give_action(action)
