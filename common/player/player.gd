class_name Player
extends RefCounted

## The player's stats and inventory. Lives on the Game autoload so it
## survives scene changes.

## Base stats. Gear bonuses are added on top (see the get_ functions)
var base_hp_stat := 10
var base_attack_power := 10
var base_agility := 10
## Current health. Each HP stat point is worth HEALTH_PER_HP_STAT health
var hp := base_hp_stat * HEALTH_PER_HP_STAT
## Free points from levelling up, spent with spend_stat_point()
var stat_points := 0
var inventory := Inventory.new()

signal leveled_up(level: int)
signal form_changed(form: Form)
signal stats_changed
## A consumable was used from the bag. message is what to show
signal item_used(message: String)

## How the player looks. Starts as a full cat and becomes more human with each
## stage, unlocked by level (see FORM_LEVELS).
enum Form {
	FULL_CAT,       ## a regular cat
	STANDING_CAT,   ## a cat that stands up
	VERY_FURRY,     ## basically a very furry person
	HALF_FURRY,     ## half-furry, half-human
	CAT_TRAITS,     ## a person with cat traits (ears, tail)
}

## What the player looks like in each form, in Form order
const FORM_SPRITES: Array[Texture2D] = [
	preload("res://common/player/art/form_0.png"),
	preload("res://common/player/art/form_1.png"),
	preload("res://common/player/art/form_2.png"),
	preload("res://common/player/art/form_3.png"),
	preload("res://common/player/art/form_4.png"),
]

## The level each form is reached at, in Form order
const FORM_LEVELS: Array[int] = [1, 5, 10, 15, 20]

const HEALTH_PER_HP_STAT := 10
## Dungeon steps per agility point
const TURNS_PER_AGILITY := 10
## Agility lost each time the owner catches the cat out of turns
const CATCH_AGILITY_PENALTY := 1
## Being caught this many times is game over
const MAX_CATCHES := 3

enum Stat { HP, ATTACK, AGILITY }

var level := 1
## Turns left before passing out. Carries over between dungeon trips until you sleep
var turns_left := base_agility * TURNS_PER_AGILITY
var xp := 0
var form := Form.FULL_CAT
var day := 1
## Whether the bird chase cutscene has played (it leads to the dungeon the first time)
var seen_bird_chase := false
## Set the first time the Falcon is beaten, which plays the courtship cutscene
var beaten_boss := false
var times_caught := 0


func _init() -> void:
	inventory.changed.connect(_on_inventory_changed)


func get_sprite() -> Texture2D:
	return FORM_SPRITES[form]


func get_max_hp() -> int:
	return base_hp_stat * HEALTH_PER_HP_STAT + inventory.get_total(&"max_hp_bonus")


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


## Escape chance against a monster at full health
const BASE_ESCAPE_CHANCE := 0.25
## Escape chance against a monster at 0 HP. It rises evenly as the monster loses health
const MAX_ESCAPE_CHANCE := 0.95
## Monsters this many levels above you can't be escaped from
const NO_ESCAPE_LEVEL_GAP := 5


## Chance that Escape works. 25% while the monster is at full health, rising
## as it gets hurt, and 0% if it's 5+ levels above you
func get_escape_chance(monster: Monster) -> float:
	if monster.level - level >= NO_ESCAPE_LEVEL_GAP:
		return 0.0
	var missing := 1.0 - float(monster.hp) / maxi(monster.max_hp, 1)
	return lerpf(BASE_ESCAPE_CHANCE, MAX_ESCAPE_CHANCE, clampf(missing, 0.0, 1.0))


## How many steps the player can take in the dungeon before passing out.
## Uses base agility only, so swapping gear doesn't change the turn count
func get_max_dungeon_turns() -> int:
	return maxi(base_agility, 0) * TURNS_PER_AGILITY


## Below this share of max HP, the cat has to sleep before going out again
const MIN_HP_TO_LEAVE := 0.25


func is_too_hurt_to_leave() -> bool:
	return hp < get_max_hp() * MIN_HP_TO_LEAVE


## Sleeping: full HP, a full set of turns, and a new day
func rest() -> void:
	hp = get_max_hp()
	turns_left = get_max_dungeon_turns()
	day += 1


## The owner catches the cat after it runs out of turns. Returns true if that
## was the last catch (game over)
func get_caught() -> bool:
	times_caught += 1
	base_agility = maxi(base_agility - CATCH_AGILITY_PENALTY, 0)
	turns_left = mini(turns_left, get_max_dungeon_turns())
	stats_changed.emit()
	return is_game_over()


func is_game_over() -> bool:
	return times_caught >= MAX_CATCHES


## Adds one to a base stat. Agility also adds its turns to the current run
func add_stat(stat: Stat, amount := 1) -> void:
	match stat:
		Stat.HP:
			base_hp_stat += amount
			hp += amount * HEALTH_PER_HP_STAT
		Stat.ATTACK:
			base_attack_power += amount
		Stat.AGILITY:
			base_agility += amount
			turns_left += amount * TURNS_PER_AGILITY
	stats_changed.emit()


## Spends a free stat point. Returns false if there are none
func spend_stat_point(stat: Stat) -> bool:
	if stat_points <= 0:
		return false
	stat_points -= 1
	add_stat(stat)
	return true


func _add_all_stats(amount: int) -> void:
	for stat in Stat.values():
		add_stat(stat, amount)


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
	item_used.emit(message)
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
		_add_all_stats(1)
		stat_points += 1
		_update_form()
		leveled_up.emit(level)
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
		# evolving gives an extra point in every stat
		_add_all_stats(1)
		form_changed.emit(form)


func _on_inventory_changed() -> void:
	# taking off max HP gear shouldn't leave you above your max
	hp = mini(hp, get_max_hp())
