class_name HealthPotion
extends Item

const HEAL_AMOUNT := 12

func _init():
	display_name = "Health Potion"
	description = "Heals %d HP." % HEAL_AMOUNT
	consumable = true

func use(player: Player) -> String:
	return "You drink the potion and heal %d HP!" % player.heal(HEAL_AMOUNT)
