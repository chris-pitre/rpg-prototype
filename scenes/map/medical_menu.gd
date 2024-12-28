extends MarginContainer


func _on_button_pressed() -> void:
	if GameState.gold >= 20:
		GameState.gold -= 20
		print("heal")
