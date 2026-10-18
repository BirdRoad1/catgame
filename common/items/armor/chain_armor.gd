class_name ChainArmor
extends Item

func _init():
	display_name = "Chain Armor"
	rarity = Rarity.UNCOMMON
	icon = preload("res://common/items/armor/art/chain_armor.png")
	description = "Jingly."
	slot = Slot.ARMOR
	max_hp_bonus = 2
	required_form = Player.Form.VERY_FURRY
