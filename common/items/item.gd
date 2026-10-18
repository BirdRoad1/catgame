class_name Item
extends RefCounted

## Base class for everything that can go in the inventory.
## Subclass it and set the fields in _init(), like monsters do.

enum Slot { NONE, HAT, COLLAR, ARMOR, WEAPON, TRINKET }

var display_name: String
var description: String
## Can be null until the item has art; the inventory shows its first letter instead
var icon: Texture2D
## Which equipment slot this goes in. NONE means it can't be equipped
var slot := Slot.NONE
## Bonuses while equipped
var attack_bonus := 0
var max_hp_bonus := 0
var agility_bonus := 0
## Extra damage dealt to the monster at the start of each of its turns
var damage_per_turn := 0
## Damage dealt back to a monster whenever it hits you
var thorns_damage := 0
## HP healed every turn in the dungeon (not during fights)
var regen_per_turn := 0
## The least human form that can equip this (forms only go up, see Player.Form)
var required_form := 0
## Consumables are used up by use()
var consumable := false


func is_equippable() -> bool:
	return slot != Slot.NONE


## Applies a consumable's effect and returns the message to show
func use(_player: Player) -> String:
	return ""


## One line per bonus, for the inventory screen
func get_bonus_text() -> String:
	var lines: PackedStringArray = []
	if attack_bonus != 0:
		lines.append("%+d attack" % attack_bonus)
	if max_hp_bonus != 0:
		lines.append("%+d max HP" % max_hp_bonus)
	if agility_bonus != 0:
		lines.append("%+d agility" % agility_bonus)
	if damage_per_turn != 0:
		lines.append("%+d damage/turn" % damage_per_turn)
	if thorns_damage != 0:
		lines.append("%d damage when hit" % thorns_damage)
	if regen_per_turn != 0:
		lines.append("%+d HP/turn out of combat" % regen_per_turn)
	return "\n".join(lines)
