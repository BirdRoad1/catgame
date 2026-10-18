class_name PoisonClaws
extends Item

func _init():
	display_name = "Poison Claws"
	rarity = Rarity.UNCOMMON
	icon = preload("res://common/items/weapons/art/poison_claws.png")
	description = "Drips with something nasty."
	slot = Slot.WEAPON
	attack_bonus = 1
	damage_per_turn = 2
