class_name NordicHelm
extends Item

func _init():
	display_name = "Nordic Helm"
	rarity = Rarity.UNCOMMON
	icon = preload("res://common/items/hats/art/nordic_helm.png")
	description = "Horns not included. Wait, yes they are."
	slot = Slot.HAT
	max_hp_bonus = 3
