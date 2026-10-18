class_name BasicClaws
extends Item

func _init():
	display_name = "Basic Claws"
	rarity = Rarity.COMMON
	icon = preload("res://common/items/weapons/art/basic_claws.png")
	description = "Your trusty claws."
	slot = Slot.WEAPON
	attack_bonus = 1
