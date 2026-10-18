class_name Rapier
extends Item

func _init():
	display_name = "Rapier"
	description = "Light enough to dance with."
	slot = Slot.WEAPON
	attack_bonus = 3
	agility_bonus = 10
	required_form = Player.Form.CAT_TRAITS
