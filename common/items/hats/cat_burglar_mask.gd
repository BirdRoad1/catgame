class_name CatBurglarMask
extends Item

func _init():
	display_name = "Cat Burglar Mask"
	rarity = Rarity.UNCOMMON
	icon = preload("res://common/items/hats/art/cat_burglar_mask.png")
	description = "For sneaking."
	slot = Slot.HAT
	agility_bonus = 5
