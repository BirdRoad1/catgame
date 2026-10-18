class_name Slime
extends Monster

func _init():
	display_name = "Slime"
	texture = preload("res://common/monsters/art/slime.png")
	max_hp = 12
	hp = max_hp
	xp_reward = 3
	attack_power = 2
	skills = [
		AttackSkill.new("Tackle", 1.0, 3.0, "The %s bounces into you for %d!"),
		AttackSkill.new("Acid Splash", 1.5, 1.0, "The %s splashes you with acid for %d!"),
		HealSkill.new("Regenerate", 4, 1.0, "The %s wobbles and regrows %d HP!"),
	]

func get_spawn_chance(_corridor: Corridor) -> float:
	return 0.4
