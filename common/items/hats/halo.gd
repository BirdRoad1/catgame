class_name Halo
extends Item

func _init():
	display_name = "Halo"
	rarity = Rarity.LEGENDARY
	icon = preload("res://common/items/hats/art/halo.png")
	description = "Glows softly. You feel blessed."
	slot = Slot.HAT
	max_hp_bonus = 10
	regen_per_turn = 2
