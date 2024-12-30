class_name StunnedStatus
extends Status

@export var stun_timesteps: int = 20
var stun: Variant = null

func decrease_stun() -> void:
	if stun == null:
		stun = stun_timesteps
	stun -= 1

func check_stun() -> bool:
	if stun == null:
		stun = stun_timesteps
	if stun > 0:
		return true
	else:
		return false
