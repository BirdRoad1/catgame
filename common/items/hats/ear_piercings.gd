class_name EarPiercings
extends Item

func _init():
	display_name = "Ear Piercings"
	rarity = Rarity.COMMON
	icon = preload("res://common/items/hats/art/ear_piercings.png")
	description = "A little edgy."
	slot = Slot.HAT
	attack_bonus = 1
	agility_bonus = 1
	max_hp_bonus = 1
