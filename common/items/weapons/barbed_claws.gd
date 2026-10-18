class_name BarbedClaws
extends Item

func _init():
	display_name = "Barbed Claws"
	rarity = Rarity.EPIC
	icon = preload("res://common/items/weapons/art/barbed_claws.png")
	description = "Hooks in and doesn't let go."
	slot = Slot.WEAPON
	attack_bonus = 7
	damage_per_turn = 2
