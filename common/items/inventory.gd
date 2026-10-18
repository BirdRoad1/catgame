class_name Inventory
extends RefCounted

## The bag (BAG_SIZE slots, empty slots are null) plus what's equipped.

signal changed

const BAG_SIZE := 24
## What each equipment slot holds, in the order the inventory screen shows them
const EQUIP_LAYOUT: Array[Item.Slot] = [
	Item.Slot.HAT, Item.Slot.COLLAR, Item.Slot.ARMOR,
	Item.Slot.WEAPON, Item.Slot.TRINKET, Item.Slot.TRINKET,
]

var bag: Array[Item] = []
var equipped: Array[Item] = []


func _init() -> void:
	bag.resize(BAG_SIZE)
	equipped.resize(EQUIP_LAYOUT.size())


## Puts the item in the first empty bag slot. Returns false if the bag is full
## Bag index of the first item of this class, or -1
func find_in_bag(script: Script) -> int:
	for i in bag.size():
		if bag[i] != null and bag[i].get_script() == script:
			return i
	return -1


func add(item: Item) -> bool:
	var index := bag.find(null)
	if index == -1:
		return false
	bag[index] = item
	changed.emit()
	return true


func remove_at(index: int) -> Item:
	var item := bag[index]
	bag[index] = null
	changed.emit()
	return item


## Equips the item at a bag index, swapping out whatever was in that slot
func equip(bag_index: int) -> bool:
	var item := bag[bag_index]
	if item == null or not item.is_equippable():
		return false

	var target := -1
	for i in EQUIP_LAYOUT.size():
		if EQUIP_LAYOUT[i] == item.slot:
			if equipped[i] == null:
				target = i
				break
			if target == -1:
				target = i
	if target == -1:
		return false

	bag[bag_index] = equipped[target]
	equipped[target] = item
	changed.emit()
	return true


## Moves an equipped item back into the bag. Returns false if the bag is full
func unequip(equip_index: int) -> bool:
	var item := equipped[equip_index]
	if item == null:
		return false
	var index := bag.find(null)
	if index == -1:
		return false
	bag[index] = item
	equipped[equip_index] = null
	changed.emit()
	return true


## Sum of one bonus (e.g. &"attack_bonus") across everything equipped
func get_total(stat: StringName) -> int:
	var total := 0
	for item in equipped:
		if item != null:
			total += item.get(stat)
	return total
