class_name RunningPaws
extends Item

func _init():
	display_name = "Running Paws"
	rarity = Rarity.COMMON
	icon = preload("res://common/items/weapons/art/running_paws.png")
	description = "Built for speed, not for fighting."
	slot = Slot.WEAPON
	agility_bonus = 3
	attack_bonus = -1
