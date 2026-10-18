class_name Fishy
extends Monster

func _init():
	display_name = "Fishy"
	texture = preload("res://common/monsters/art/fishy.png")
	level = 2
	max_hp = 22
	hp = max_hp
	xp_reward = 4
	attack_power = 4
	max_sp = 10
	skills = [
		AttackSkill.new("Flop", 1.0, 3.0, "The %s flops into you for %d!"),
		AttackSkill.new("Tail Slap", 1.5, 1.0, "The %s slaps you with its tail for %d!", 3),
		HealSkill.new("Splash Around", 5, 1.0, "The %s splashes in a puddle and heals %d HP!", 6),
	]

## A tasty-looking snack, and about as common as slimes
func get_spawn_chance(_corridor: Corridor) -> float:
	return 0.3
