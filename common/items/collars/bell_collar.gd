class_name BellCollar
extends Item

func _init():
	display_name = "Bell Collar"
	rarity = Rarity.COMMON
	icon = preload("res://common/items/collars/art/bell_collar.png")
	description = "Jingles when you walk."
	slot = Slot.COLLAR
	max_hp_bonus = 3
