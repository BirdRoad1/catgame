class_name Player
extends RefCounted

## The player's stats and inventory. Lives on the Game autoload so it
## survives scene changes.

var base_max_hp := 30
var base_attack_power := 4
var base_agility := 0
var hp := base_max_hp
var inventory := Inventory.new()

signal leveled_up(level: int)
signal form_changed(form: Form)

## How the player looks. Starts as a full cat and becomes more human with each
## stage, unlocked by level (see FORM_LEVELS).
enum Form {
	FULL_CAT,       ## a regular cat
	STANDING_CAT,   ## a cat that stands up
	VERY_FURRY,     ## basically a very furry person
	HALF_FURRY,     ## half-furry, half-human
	CAT_TRAITS,     ## a person with cat traits (ears, tail)
}

## The level each form is reached at, in Form order
const FORM_LEVELS: Array[int] = [1, 3, 5, 7, 10]

## Dungeon steps before passing out, and how many more each level adds
const BASE_DUNGEON_TURNS := 40
const TURNS_PER_LEVEL := 5

var level := 1
## Turns left before passing out. Carries over between dungeon trips until you sleep
var turns_left := BASE_DUNGEON_TURNS
var xp := 0
var form := Form.FULL_CAT


func _init() -> void:
	inventory.changed.connect(_on_inventory_changed)


func get_max_hp() -> int:
	return base_max_hp + inventory.get_total(&"max_hp_bonus")


func get_attack_power() -> int:
	return maxi(base_attack_power + inventory.get_total(&"attack_bonus"), 1)


func get_agility() -> int:
	return base_agility + inventory.get_total(&"agility_bonus")


func get_damage_per_turn() -> int:
	return inventory.get_total(&"damage_per_turn")


func get_thorns_damage() -> int:
	return inventory.get_total(&"thorns_damage")


func get_regen_per_turn() -> int:
	return inventory.get_total(&"regen_per_turn")


## Chance to dodge a monster's attack. 2% per agility point, up to 50%
func get_dodge_chance() -> float:
	return clampf(get_agility() * 0.02, 0.0, 0.5)


## Chance that Escape works. 50%, plus 3% per agility point
func get_escape_chance() -> float:
	return clampf(0.5 + get_agility() * 0.03, 0.1, 0.95)


## How many steps the player can take in the dungeon before passing out
func get_max_dungeon_turns() -> int:
	return BASE_DUNGEON_TURNS + (level - 1) * TURNS_PER_LEVEL


## Sleeping: full HP and a full set of turns
func rest() -> void:
	hp = get_max_hp()
	turns_left = get_max_dungeon_turns()


## Whether the current form is allowed to wear this item
func can_equip(item: Item) -> bool:
	return item != null and item.is_equippable() and form >= item.required_form


## Equips the item at a bag index if the current form allows it
func equip(bag_index: int) -> bool:
	if not can_equip(inventory.bag[bag_index]):
		return false
	return inventory.equip(bag_index)


func take_damage(amount: int) -> void:
	hp = maxi(hp - amount, 0)


## Returns how much was actually healed
func heal(amount: int) -> int:
	var healed := mini(amount, get_max_hp() - hp)
	hp += healed
	return healed


## Uses (and removes) the consumable at a bag index. Returns the message to show
func use_item(bag_index: int) -> String:
	var item := inventory.bag[bag_index]
	if item == null or not item.consumable:
		return ""
	var message := item.use(self)
	inventory.remove_at(bag_index)
	return message


## XP needed to go from the current level to the next
func get_xp_to_next_level() -> int:
	return level * 10


## Adds XP, levelling up (possibly several times) and changing form when due.
## Returns how many levels were gained
func gain_xp(amount: int) -> int:
	xp += amount
	var gained := 0
	while xp >= get_xp_to_next_level():
		xp -= get_xp_to_next_level()
		level += 1
		gained += 1
		turns_left += TURNS_PER_LEVEL
		leveled_up.emit(level)
		_update_form()
	return gained


static func get_form_for_level(p_level: int) -> Form:
	var result := Form.FULL_CAT
	for i in FORM_LEVELS.size():
		if p_level >= FORM_LEVELS[i]:
			result = i as Form
	return result


func _update_form() -> void:
	var new_form := get_form_for_level(level)
	if new_form != form:
		form = new_form
		form_changed.emit(form)


func _on_inventory_changed() -> void:
	# taking off max HP gear shouldn't leave you above your max
	hp = mini(hp, get_max_hp())
