extends "res://tests/test_case.gd"
## Tests for monsters scaling with the player's level (common/monsters/monster.gd)


func test_level_one_player_gets_base_monster() -> void:
	var slime := Slime.new()
	slime.scale_to_player_level(1)
	assert_eq(slime.level, 1)
	assert_eq(slime.max_hp, 12)
	assert_eq(slime.attack_power, 2)


func test_monsters_grow_with_player() -> void:
	var mimic := Mimic.new()
	mimic.scale_to_player_level(11)
	assert_eq(mimic.level, 14, "keeps its 3 level lead")
	assert_eq(mimic.max_hp, 75)
	assert_eq(mimic.hp, mimic.max_hp)
	assert_eq(mimic.attack_power, 18)
	assert_eq(mimic.xp_reward, 38)


func test_heals_grow_too() -> void:
	var mouse := Mouse.new()
	mouse.scale_to_player_level(5)
	for skill in mouse.skills:
		if skill is HealSkill:
			assert_eq(skill.amount, 5)


func test_spawner_scales_monsters() -> void:
	seed(99)
	var Spawner = preload("res://scenes/dungeon/monster_spawner.gd")
	var Corridor = preload("res://scenes/dungeon/dungeon.gd").Corridor
	var spawner = Spawner.new()
	var monster: Monster = null
	for i in 1000:
		monster = spawner.roll(Corridor.new(), 6)
		if monster != null:
			break
	assert_not_null(monster)
	assert_true(monster.level >= 6)
