class_name LootTable
extends RefCounted

## Monster drops. Any item can drop, picked by rarity weight, and a monster
## drops at most one item.

## Every item that can drop. Add new items here
const ITEMS: Array[Script] = [
	preload("res://common/items/armor/chain_armor.gd"),
	preload("res://common/items/armor/heavy_armor.gd"),
	preload("res://common/items/armor/iron_armor.gd"),
	preload("res://common/items/armor/leather_armor.gd"),
	preload("res://common/items/armor/light_armor.gd"),
	preload("res://common/items/armor/spiky_armor.gd"),
	preload("res://common/items/collars/bell_collar.gd"),
	preload("res://common/items/consumables/chest_search.gd"),
	preload("res://common/items/consumables/milk_potion.gd"),
	preload("res://common/items/consumables/panacea.gd"),
	preload("res://common/items/hats/cat_burglar_mask.gd"),
	preload("res://common/items/hats/ear_piercings.gd"),
	preload("res://common/items/hats/fedora.gd"),
	preload("res://common/items/hats/flower.gd"),
	preload("res://common/items/hats/halo.gd"),
	preload("res://common/items/hats/nordic_helm.gd"),
	preload("res://common/items/hats/ski_mask.gd"),
	preload("res://common/items/trinkets/lucky_paw.gd"),
	preload("res://common/items/weapons/barbed_claws.gd"),
	preload("res://common/items/weapons/basic_claws.gd"),
	preload("res://common/items/weapons/fire_claws.gd"),
	preload("res://common/items/weapons/great_sword.gd"),
	preload("res://common/items/weapons/katana.gd"),
	preload("res://common/items/weapons/long_claws.gd"),
	preload("res://common/items/weapons/obsidian_claws.gd"),
	preload("res://common/items/weapons/poison_claws.gd"),
	preload("res://common/items/weapons/rapier.gd"),
	preload("res://common/items/weapons/running_paws.gd"),
]

## How often each rarity is picked compared to the others, in Item.Rarity order
const RARITY_WEIGHTS: Array[float] = [50.0, 25.0, 15.0, 8.0, 2.0]


## Returns the item a beaten monster drops, or null for nothing
static func roll_drop(monster: Monster) -> Item:
	if randf() >= monster.drop_chance:
		return null
	return roll_item()


## Picks one item: first a rarity by weight, then an item of that rarity
static func roll_item() -> Item:
	var by_rarity := {}
	for script in ITEMS:
		var item: Item = script.new()
		if not by_rarity.has(item.rarity):
			by_rarity[item.rarity] = []
		by_rarity[item.rarity].append(script)

	# only rarities that have items can be picked
	var total := 0.0
	for rarity in by_rarity:
		total += RARITY_WEIGHTS[rarity]
	var roll := randf() * total
	for rarity in by_rarity:
		roll -= RARITY_WEIGHTS[rarity]
		if roll < 0.0:
			return by_rarity[rarity].pick_random().new()
	return by_rarity[by_rarity.keys().back()].pick_random().new()
