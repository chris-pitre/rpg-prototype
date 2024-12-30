extends VBoxContainer

@export var is_player: bool = false

@onready var guard_label := $GuardLabel
@onready var stun_label := $StunLabel

func _ready() -> void:
	BattleManager.next_execution_timestep.connect(_update_statuses)

func _update_statuses() -> void:
	var actor: BattleActorStats
	if is_player:
		actor = BattleManager.player
	else:
		actor = BattleManager.enemy
	
	if actor.current_guard != GuardStatus.GUARD.NONE:
		match actor.current_guard:
			GuardStatus.GUARD.HIGH_GUARD:
				guard_label.text = "High Guard"
			GuardStatus.GUARD.MIDDLE_GUARD:
				guard_label.text = "Middle Guard"
			GuardStatus.GUARD.LOW_GUARD:
				guard_label.text = "Low Guard"
		guard_label.show()
	else:
		guard_label.hide()
		
	if actor.stun != null:
		print(actor.stun.stun)
		stun_label.text = "Stunned %d" % [actor.stun.stun]
		stun_label.show()
	else:
		stun_label.hide()
