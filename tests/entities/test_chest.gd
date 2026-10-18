extends "res://tests/test_case.gd"
## Tests for chests and mimics (common/entities/chest.gd)

const Corridor = preload("res://scenes/dungeon/dungeon.gd").Corridor


func before_each() -> void:
	seed(2024)


func _dead_end() -> Corridor:
	var corridor := Corridor.new()
	corridor.open_directions = [0]
	return corridor


func test_dead_ends_spawn_chests_more_often() -> void:
	assert_true(Chest.get_spawn_chance(_dead_end()) > Chest.get_spawn_chance(Corridor.new()))


func test_about_a_quarter_of_chests_are_mimics() -> void:
	var chests := 0
	var mimics := 0
	for i in 20000:
		var chest := Chest.roll(_dead_end())
		if chest != null:
			chests += 1
			if chest.is_mimic:
				mimics += 1
	var spawn_rate := chests / 20000.0
	var mimic_rate := float(mimics) / chests
	print("spawn rate %.3f, mimic rate %.3f" % [spawn_rate, mimic_rate])
	assert_between(spawn_rate, 0.27, 0.33)
	assert_between(mimic_rate, 0.22, 0.28)


func test_mimics_no_longer_spawn_on_their_own() -> void:
	var spawner = preload("res://scenes/dungeon/monster_spawner.gd").new()
	for i in 2000:
		assert_false(spawner.roll(_dead_end()) is Mimic)
