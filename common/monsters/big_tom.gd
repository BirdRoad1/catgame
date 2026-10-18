class_name BigTom
extends Monster

## The boss: the alley cat who rules the dungeon. Only shows up once the
## player is level BOSS_MIN_LEVEL or higher (see Monster.min_player_level)

func _init():
	display_name = "Big Tom"
	# TODO art: placeholder until the boss is drawn
	texture = preload("res://common/monsters/art/boss_placeholder.png")
	level = 25
	min_player_level = 25
	max_hp = 360
	hp = max_hp
	xp_reward = 300
	attack_power = 23
	crit_chance = 0.12
	max_sp = 25
	skills = [
		AttackSkill.new("Swipe", 1.0, 3.0, "The %s swipes at you for %d!"),
		AttackSkill.new("Pounce", 1.5, 1.5, "The %s pounces, pinning you down for %d!", 3),
		AttackSkill.new("Yowl", 0.7, 1.0, "The %s lets out a deafening yowl! %d damage!"),
		AttackSkill.new("Nine Lives Fury", 2.2, 0.5, "The %s goes into a frenzy of claws for %d!", 6),
		HealSkill.new("Groom", 20, 0.8, "The %s grooms itself and heals %d HP!", 8),
	]

## Rarely 'rare': once you're strong enough, he comes looking for you
func get_spawn_chance(_corridor: Corridor) -> float:
	return 0.5


## Bosses don't roll a random level: always a few levels above the player
func scale_to_player_level(player_level: int) -> void:
	scale_to_level(maxi(player_level + 3, level))
