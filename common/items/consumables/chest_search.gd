class_name ChestSearch
extends Item

## Used from the chest prompt (not the bag): shows whether a chest is a mimic

func _init():
	display_name = "Chest Search"
	rarity = Rarity.UNCOMMON
	icon = preload("res://common/items/consumables/art/chest_search.png")
	description = "Checks whether a chest is really a mimic. Use it when you find a chest."
