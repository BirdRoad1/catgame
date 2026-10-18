extends "res://tests/test_case.gd"
## Tests for monsters scaling with the player's level (common/monsters/monster.gd)


func before_each() -> void:
	seed(77)


func test_base_level_keeps_base_stats() -> void:
	var slime := Slime.new()
	slime.scale_to_level(1)
	assert_eq(slime.level, 1)
	assert_eq(slime.max_hp, 24)
	assert_eq(slime.attack_power, 4)


func test_stats_grow_per_level_above_base() -> void:
	var mimic := Mimic.new() # base level 4
	mimic.scale_to_level(14)
	assert_eq(mimic.level, 14)
	assert_eq(mimic.max_hp, 125)
	assert_eq(mimic.hp, mimic.max_hp)
	assert_eq(mimic.attack_power, 20)
	assert_eq(mimic.xp_reward, 38)


func test_stats_shrink_below_base_but_stay_positive() -> void:
	var mimic := Mimic.new()
	mimic.scale_to_level(1)
	assert_eq(mimic.level, 1)
	assert_true(mimic.max_hp < 50 and mimic.max_hp >= 1)
	assert_true(mimic.attack_power >= 1)


func test_heals_grow_too() -> void:
	var mouse := Mouse.new() # base level 2, heals 5
	mouse.scale_to_level(6)
	for skill in mouse.skills:
		if skill is HealSkill:
			assert_eq(skill.amount, 8)


func test_spawn_levels_range_from_minus_two_to_plus_five() -> void:
	var seen := {}
	for i in 2000:
		var slime := Slime.new()
		slime.scale_to_player_level(10)
		assert_between(slime.level, 8, 15)
		seen[slime.level] = true
	assert_eq(seen.size(), 8, "every level from 8 to 15 shows up")


func test_spawn_level_never_below_one() -> void:
	for i in 500:
		var slime := Slime.new()
		slime.scale_to_player_level(1)
		assert_true(slime.level >= 1)


func test_spawner_scales_monsters() -> void:
	var Spawner = preload("res://scenes/dungeon/monster_spawner.gd")
	var Corridor = preload("res://scenes/dungeon/dungeon.gd").Corridor
	var spawner = Spawner.new()
	var monster: Monster = null
	for i in 1000:
		monster = spawner.roll(Corridor.new(), 6)
		if monster != null:
			break
	assert_not_null(monster)
	assert_between(monster.level, 4, 11)


func test_cat_is_the_strongest_regular_monster() -> void:
	var cat := CatEnemy.new()
	for other in [Slime.new(), Mouse.new()]:
		assert_true(cat.max_hp > other.max_hp and cat.attack_power > other.attack_power)
	var spawner = preload("res://scenes/dungeon/monster_spawner.gd").new()
	assert_has(spawner.monsters, CatEnemy)


func test_every_form_has_a_sprite() -> void:
	var player := Player.new()
	for form in Player.Form.values():
		player.form = form
		assert_not_null(player.get_sprite())


class FakeBattle extends Node:
	var last_damage := 0
	func damage_player(amount: int) -> int:
		last_damage = amount
		return amount


func test_crits_are_rare_and_hit_1_2_to_1_4x() -> void:
	var battle := FakeBattle.new()
	var monster := Monster.new()
	monster.attack_power = 100
	var skill := AttackSkill.new("Hit", 1.0, 1.0, "%s %d")
	var crits := 0
	for i in 5000:
		var text := skill.use(monster, battle)
		if text.begins_with("Critical strike!"):
			crits += 1
			assert_between(battle.last_damage, 120, 140)
		else:
			assert_eq(battle.last_damage, 100)
	battle.free()
	assert_between(crits / 5000.0, 0.06, 0.10)


func _spawn_counts(player_level: int) -> Dictionary:
	var spawner = preload("res://scenes/dungeon/monster_spawner.gd").new()
	var Corridor = preload("res://scenes/dungeon/dungeon.gd").Corridor
	var counts := {}
	for i in 4000:
		var m: Monster = spawner.roll(Corridor.new(), player_level)
		if m != null:
			counts[m.display_name] = counts.get(m.display_name, 0) + 1
	return counts


func test_boss_never_spawns_below_level_25() -> void:
	assert_false(_spawn_counts(24).has("Falcon"))


func test_boss_spawns_often_from_level_25() -> void:
	var counts := _spawn_counts(25)
	var total := 0
	for n in counts.values():
		total += n
	print("level 25 spawns: ", counts)
	assert_between(counts.get("Falcon", 0) / float(total), 0.3, 0.45)


func test_boss_is_always_three_levels_above() -> void:
	var boss := Falcon.new()
	boss.scale_to_player_level(28)
	assert_eq(boss.level, 31)


func test_courtship_scene_loads_and_goes_home() -> void:
	var scene: Node = load("res://scenes/courtship/courtship.tscn").instantiate()
	assert_eq(scene.next_scene, "res://scenes/home/catroom/catroom.tscn")
	assert_eq(scene.get_node("DialogueBox").dialogue_resource.resource_path, "res://scenes/courtship/courtship.dialogue")
	scene.free()


func test_monsters_cant_heal_forever() -> void:
	var battle := FakeBattle.new()
	var slime := Slime.new()
	var heals := 0
	for turn in 60:
		slime.hp = 1 # always hurt, so it always wants to heal
		slime.regen_sp()
		var skill := slime.choose_skill(battle)
		if skill is HealSkill:
			heals += 1
		slime.use_skill(skill, battle)
	battle.free()
	# 10 starting SP + 1 per turn, 6 per heal: about 11 heals in 60 turns, not 60
	assert_true(heals <= 12, "healed %d times" % heals)
	assert_true(heals >= 1)


func test_skills_cost_sp_and_unaffordable_ones_are_skipped() -> void:
	var battle := Node.new()
	var slime := Slime.new()
	slime.sp = 0
	for i in 200:
		slime.hp = 1
		var skill := slime.choose_skill(battle)
		assert_eq(skill.sp_cost, 0, "only free skills at 0 SP")
	battle.free()
