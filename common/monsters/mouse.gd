class_name Mouse
extends Monster

func _init():
	display_name = "Mouse"
	texture = preload("res://common/monsters/art/mouse.png")
	level = 2
	max_hp = 8
	hp = max_hp
	xp_reward = 4
	attack_power = 3
	skills = [
		AttackSkill.new("Bite", 1.0, 3.0, "The %s bites you for %d!"),
		AttackSkill.new("Frenzy", 1.7, 1.0, "The %s goes into a frenzy, clawing you for %d!"),
		HealSkill.new("Nibble Crumbs", 3, 1.0, "The %s nibbles some crumbs and heals %d HP!"),
	]

func get_spawn_chance(_corridor: Corridor) -> float:
	return 0.3
