extends "res://tests/test_case.gd"
## Tests for item rarity and monster drops (common/items/loot_table.gd)


func before_each() -> void:
	seed(4242)


func test_every_item_drops_and_has_a_rarity() -> void:
	for script in LootTable.ITEMS:
		var item: Item = script.new()
		assert_between(item.rarity, Item.Rarity.COMMON, Item.Rarity.LEGENDARY, item.display_name)


func test_drops_at_most_one_item() -> void:
	var monster := Monster.new()
	monster.drop_chance = 1.0
	for i in 200:
		assert_true(LootTable.roll_drop(monster) is Item)


func test_no_drop_chance_never_drops() -> void:
	var monster := Monster.new()
	monster.drop_chance = 0.0
	for i in 200:
		assert_null(LootTable.roll_drop(monster))


func test_common_drops_more_than_legendary() -> void:
	var counts := [0, 0, 0, 0, 0]
	for i in 5000:
		counts[LootTable.roll_item().rarity] += 1
	print("rarity counts: ", counts)
	assert_true(counts[Item.Rarity.COMMON] > counts[Item.Rarity.LEGENDARY])
	assert_true(counts[Item.Rarity.LEGENDARY] > 0, "legendaries can still drop")
