class_name Falcon
extends Monster

## The final boss: the falcon who rules the dungeon. Only shows up once the
## player is level 25 or higher (see Monster.min_player_level)

func _init():
	display_name = "Falcon"
	texture = preload("res://common/monsters/art/falcon.png")
	level = 25
	min_player_level = 25
	max_hp = 360
	hp = max_hp
	xp_reward = 300
	attack_power = 23
	crit_chance = 0.12
	max_sp = 25
	skills = [
		AttackSkill.new("Talon Swipe", 1.0, 3.0, "The %s rakes you with its talons for %d!"),
		AttackSkill.new("Dive Bomb", 1.5, 1.5, "The %s dives from above and slams into you for %d!", 3),
		AttackSkill.new("Screech", 0.7, 1.0, "The %s lets out a piercing screech! %d damage!"),
		AttackSkill.new("Sky Fury", 2.2, 0.5, "The %s whirls into a storm of beak and talons for %d!", 6),
		HealSkill.new("Preen", 20, 0.8, "The %s preens its feathers and heals %d HP!", 8),
	]

## Once you're strong enough, it comes hunting for you
func get_spawn_chance(_corridor: Corridor) -> float:
	return 0.8


## Bosses don't roll a random level: always a few levels above the player
func scale_to_player_level(player_level: int) -> void:
	scale_to_level(maxi(player_level + 3, level))
