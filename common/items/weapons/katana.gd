class_name Katana
extends Item

func _init():
	display_name = "Katana"
	description = "Fast and deadly."
	slot = Slot.WEAPON
	attack_bonus = 7
	agility_bonus = 5
	required_form = Player.Form.CAT_TRAITS
