class_name GreatSword
extends Item

func _init():
	display_name = "Great Sword"
	description = "Needs two very human hands."
	slot = Slot.WEAPON
	attack_bonus = 12
	agility_bonus = -3
	required_form = Player.Form.CAT_TRAITS
