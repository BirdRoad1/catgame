class_name Flower
extends Item

func _init():
	display_name = "Flower"
	rarity = Rarity.COMMON
	icon = preload("res://common/items/hats/art/flower.png")
	description = "Smells nice."
	slot = Slot.HAT
	max_hp_bonus = 1
