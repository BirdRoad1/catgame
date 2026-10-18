class_name CatEnemy
extends Monster

func _init():
	display_name = "Alley Cat"
	texture = preload("res://common/monsters/art/cat_enemy.png")
	level = 5
	max_hp = 60
	hp = max_hp
	xp_reward = 25
	attack_power = 9
	max_sp = 15
	skills = [
		AttackSkill.new("Scratch", 1.0, 3.0, "The %s scratches you for %d!"),
		AttackSkill.new("Pounce", 1.6, 1.5, "The %s pounces on you for %d!", 3),
		AttackSkill.new("Zoomies", 0.6, 1.0, "The %s gets the zoomies and slams into you for %d!"),
		AttackSkill.new("Hairball", 2.2, 0.5, "The %s hacks up a hairball at you! %d damage!", 5),
		HealSkill.new("Lick Wounds", 10, 1.0, "The %s licks its wounds and heals %d HP!", 6),
	]

## Rarer than slimes and mice
func get_spawn_chance(_corridor: Corridor) -> float:
	return 0.12
