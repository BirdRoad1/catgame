class_name LongClaws
extends Item

func _init():
	display_name = "Long Claws"
	rarity = Rarity.UNCOMMON
	icon = preload("res://common/items/weapons/art/long_claws.png")
	description = "Extra reach."
	slot = Slot.WEAPON
	attack_bonus = 3
	agility_bonus = 1
