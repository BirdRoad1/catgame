class_name SpikyArmor
extends Item

func _init():
	display_name = "Spiky Armor"
	description = "Hurts whoever hits you."
	slot = Slot.ARMOR
	max_hp_bonus = 2
	thorns_damage = 5
	required_form = Player.Form.VERY_FURRY
