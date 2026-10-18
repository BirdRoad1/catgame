class_name SkiMask
extends Item

func _init():
	display_name = "Ski Mask"
	rarity = Rarity.UNCOMMON
	icon = preload("res://common/items/hats/art/ski_mask.png")
	description = "Suspicious."
	slot = Slot.HAT
	attack_bonus = 3
	agility_bonus = 2
