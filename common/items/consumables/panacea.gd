class_name Panacea
extends Item

func _init():
	display_name = "Panacea"
	rarity = Rarity.RARE
	icon = preload("res://common/items/consumables/art/panacea.png")
	description = "Permanently adds 1 to a random stat."
	consumable = true

func use(player: Player) -> String:
	var stat: Player.Stat = Player.Stat.values().pick_random()
	player.add_stat(stat)
	return "You drink the panacea. +1 %s!" % ["HP", "attack", "agility"][stat]
