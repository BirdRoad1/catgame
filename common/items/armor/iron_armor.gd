class_name IronArmor
extends Item

func _init():
	display_name = "Iron Armor"
	rarity = Rarity.UNCOMMON
	icon = preload("res://common/items/armor/art/iron_armor.png")
	description = "Solid and heavy."
	slot = Slot.ARMOR
	max_hp_bonus = 4
	required_form = Player.Form.VERY_FURRY
