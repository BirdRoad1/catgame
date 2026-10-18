class_name HeavyArmor
extends Item

func _init():
	display_name = "Heavy Armor"
	description = "Like wearing a wall."
	slot = Slot.ARMOR
	max_hp_bonus = 10
	agility_bonus = -5
	required_form = Player.Form.VERY_FURRY
