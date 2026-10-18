class_name ObsidianClaws
extends Item

func _init():
	display_name = "Obsidian Claws"
	rarity = Rarity.RARE
	icon = preload("res://common/items/weapons/art/obsidian_claws.png")
	description = "Sharp as volcanic glass."
	slot = Slot.WEAPON
	attack_bonus = 5
