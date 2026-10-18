class_name LightArmor
extends Item

func _init():
	display_name = "Light Armor"
	rarity = Rarity.RARE
	icon = preload("res://common/items/armor/art/light_armor.png")
	description = "Barely slows you down."
	slot = Slot.ARMOR
	max_hp_bonus = 2
	agility_bonus = 5
	required_form = Player.Form.VERY_FURRY
