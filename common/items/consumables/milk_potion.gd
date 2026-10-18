class_name MilkPotion
extends Item

const HEAL_AMOUNT := 10

func _init():
	display_name = "Milk Potion"
	rarity = Rarity.COMMON
	icon = preload("res://common/items/consumables/art/milk_potion.png")
	description = "Heals %d HP." % HEAL_AMOUNT
	consumable = true

func use(player: Player) -> String:
	return "You lap up the milk and heal %d HP!" % player.heal(HEAL_AMOUNT)
