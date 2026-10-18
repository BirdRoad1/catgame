class_name Mimic
extends Monster

func _init():
	display_name = "Mimic"
	texture = preload("res://common/monsters/art/mimic_open.png")
	level = 4
	max_hp = 50
	hp = max_hp
	xp_reward = 15
	attack_power = 8
	max_sp = 12
	skills = [
		AttackSkill.new("Chomp", 1.0, 3.0, "The %s chomps down on you for %d!"),
		AttackSkill.new("Tongue Lash", 0.6, 2.0, "The %s lashes you with its tongue for %d!"),
		AttackSkill.new("Swallow", 1.6, 1.0, "The %s tries to swallow you whole! %d damage!", 4),
		HealSkill.new("Snack on Loot", 8, 1.0, "The %s crunches on some loot and heals %d HP!", 6),
	]

func get_spawn_chance(corridor: Corridor) -> float:
	# mimics like to hide in dead ends
	if corridor.open_directions.size() == 1:
		return 0.15
	return 0.02
