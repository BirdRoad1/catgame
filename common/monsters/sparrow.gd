class_name Sparrow
extends Monster

## Small and fragile, but quick and pecks hard (higher crit chance)

func _init():
	display_name = "Sparrow"
	texture = preload("res://common/monsters/art/sparrow.png")
	level = 3
	max_hp = 16
	hp = max_hp
	xp_reward = 6
	attack_power = 6
	crit_chance = 0.15
	max_sp = 10
	skills = [
		AttackSkill.new("Peck", 1.0, 3.0, "The %s pecks you for %d!"),
		AttackSkill.new("Dive", 1.6, 1.0, "The %s dives at your face for %d!", 3),
		HealSkill.new("Preen", 4, 1.0, "The %s preens its feathers and heals %d HP!", 6),
	]

func get_spawn_chance(_corridor: Corridor) -> float:
	return 0.25
