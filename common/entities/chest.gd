class_name Chest
extends RefCounted

## A chest in a corridor. It might really be a mimic: that's decided when the
## chest spawns, but the player only finds out when they open it.

const DungeonScript = preload("res://scenes/dungeon/dungeon.gd")
const Corridor = DungeonScript.Corridor

## Chance a spawned chest is really a mimic
const MIMIC_CHANCE := 0.25

const CLOSED_TEXTURE := preload("res://common/entities/art/chest_closed.png")
const OPEN_TEXTURE := preload("res://common/entities/art/chest_open.png")
## Shown when a Chest Search reveals a mimic
const MIMIC_CLOSED_TEXTURE := preload("res://common/monsters/art/mimic_closed.png")

var is_mimic := false


## Rolls whether a chest spawns in this corridor, then whether it's a mimic.
## Returns null if nothing spawns
static func roll(corridor: Corridor) -> Chest:
	if randf() >= get_spawn_chance(corridor):
		return null
	var chest := Chest.new()
	chest.is_mimic = randf() < MIMIC_CHANCE
	return chest


## Chests hide in dead ends too, so you never know if it's a mimic
static func get_spawn_chance(corridor: Corridor) -> float:
	if corridor.open_directions.size() == 1:
		return 0.3
	return 0.05
