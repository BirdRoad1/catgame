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


func test_new_consumables_can_drop() -> void:
	var names := []
	for script in LootTable.ITEMS:
		names.append(script.new().display_name)
	assert_has(names, "Panacea")
	assert_has(names, "Chest Search")
	assert_has(names, "Milk Potion")


func test_panacea_adds_one_to_a_stat() -> void:
	var player := Player.new()
	var before: int = player.base_hp_stat + player.base_attack_power + player.base_agility
	Panacea.new().use(player)
	assert_eq(player.base_hp_stat + player.base_attack_power + player.base_agility, before + 1)


func test_milk_potion_heals_ten() -> void:
	var player := Player.new()
	player.hp = 50
	MilkPotion.new().use(player)
	assert_eq(player.hp, 60)


func test_chest_search_is_found_in_bag() -> void:
	var inventory := Inventory.new()
	assert_eq(inventory.find_in_bag(ChestSearch), -1)
	inventory.add(MilkPotion.new())
	inventory.add(ChestSearch.new())
	assert_eq(inventory.find_in_bag(ChestSearch), 1)
	assert_false(ChestSearch.new().consumable, "only used from the chest prompt")


func test_deleting_items_from_bag_and_equipment() -> void:
	var inventory := Inventory.new()
	inventory.add(Fedora.new())
	inventory.add(BasicClaws.new())
	inventory.equip(1)
	assert_not_null(inventory.remove_at(0))
	assert_null(inventory.bag[0])
	var weapon_slot := Inventory.EQUIP_LAYOUT.find(Item.Slot.WEAPON)
	assert_true(inventory.remove_equipped(weapon_slot) is BasicClaws)
	assert_null(inventory.equipped[weapon_slot])
