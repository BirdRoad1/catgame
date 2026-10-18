class_name LeatherArmor
extends Item

func _init():
	display_name = "Leather Armor"
	description = "A little stiff, but it helps."
	slot = Slot.ARMOR
	max_hp_bonus = 1
	required_form = Player.Form.VERY_FURRY
