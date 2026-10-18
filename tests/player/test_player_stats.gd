extends "res://tests/test_case.gd"
## Tests for Player stats, levelling, evolution, catches and days (common/player/player.gd)

var player: Player


func before_each() -> void:
	player = Player.new()


func test_starting_stats() -> void:
	assert_eq(player.base_hp_stat, 10)
	assert_eq(player.get_max_hp(), 100)
	assert_eq(player.hp, 100)
	assert_eq(player.base_attack_power, 10)
	assert_eq(player.base_agility, 10)
	assert_eq(player.get_max_dungeon_turns(), 100)
	assert_eq(player.turns_left, 100)
	assert_eq(player.day, 1)
	assert_eq(player.times_caught, 0)


func test_level_up_gives_one_to_each_stat_and_a_free_point() -> void:
	player.gain_xp(player.get_xp_to_next_level())
	assert_eq(player.level, 2)
	assert_eq(player.base_hp_stat, 11)
	assert_eq(player.base_attack_power, 11)
	assert_eq(player.base_agility, 11)
	assert_eq(player.stat_points, 1)


func _level_to(target: int) -> void:
	while player.level < target:
		player.gain_xp(player.get_xp_to_next_level())


func test_evolution_levels() -> void:
	_level_to(4)
	assert_eq(player.form, Player.Form.FULL_CAT)
	_level_to(5)
	assert_eq(player.form, Player.Form.STANDING_CAT)
	_level_to(10)
	assert_eq(player.form, Player.Form.VERY_FURRY)
	_level_to(15)
	assert_eq(player.form, Player.Form.HALF_FURRY)
	_level_to(20)
	assert_eq(player.form, Player.Form.CAT_TRAITS)


func test_evolution_gives_extra_point_in_each_stat() -> void:
	_level_to(5)
	# 4 level ups (+4) and one evolution (+1)
	assert_eq(player.base_hp_stat, 15)
	assert_eq(player.base_attack_power, 15)
	assert_eq(player.base_agility, 15)
	assert_eq(player.stat_points, 4)


func test_spending_stat_points() -> void:
	assert_false(player.spend_stat_point(Player.Stat.ATTACK))
	player.stat_points = 1
	assert_true(player.spend_stat_point(Player.Stat.ATTACK))
	assert_eq(player.base_attack_power, 11)
	assert_eq(player.stat_points, 0)


func test_getting_caught_costs_agility_and_three_is_game_over() -> void:
	assert_false(player.get_caught())
	assert_eq(player.base_agility, 10 - Player.CATCH_AGILITY_PENALTY)
	assert_false(player.get_caught())
	assert_true(player.get_caught())
	assert_true(player.is_game_over())


func test_sleeping_heals_refills_turns_and_advances_day() -> void:
	player.hp = 1
	player.turns_left = 0
	player.rest()
	assert_eq(player.hp, 100)
	assert_eq(player.turns_left, 100)
	assert_eq(player.day, 2)


func test_base_regen_is_zero() -> void:
	player.inventory = Inventory.new()
	assert_eq(player.get_regen_per_turn(), 0)
