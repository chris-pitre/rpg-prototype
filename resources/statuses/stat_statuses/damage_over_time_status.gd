class_name DamageOverTimeStatus
extends StatStatus

@export var amount_per_timestep: float = 1

var delta: float = 0.0

func decrease_duration(battle_actor_stats: BattleActorStats) -> void:
	super(battle_actor_stats)
	delta += amount_per_timestep
	if delta >= 1:
		delta -= 1
		battle_actor_stats.hp -= amount_per_timestep
	
