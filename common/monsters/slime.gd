class_name Slime
extends Monster

func _init():
	display_name = "Slime"
	texture = preload("res://common/monsters/art/slime.png")
	max_hp = 24
	hp = max_hp
	xp_reward = 3
	attack_power = 4
	max_sp = 10
	skills = [
		AttackSkill.new("Tackle", 1.0, 3.0, "The %s bounces into you for %d!"),
		AttackSkill.new("Acid Splash", 1.5, 1.0, "The %s splashes you with acid for %d!", 3),
		HealSkill.new("Regenerate", 6, 1.0, "The %s wobbles and regrows %d HP!", 6),
	]

func get_spawn_chance(_corridor: Corridor) -> float:
	return 0.4
