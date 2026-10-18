extends RefCounted

## Decides which monster (if any) shows up in a corridor.
## Each monster's get_spawn_chance() is used as its weight when picking.

const DungeonScript = preload("res://scenes/dungeon/dungeon.gd")
const Corridor = DungeonScript.Corridor

## Chance that entering a new corridor starts a fight at all
const ENCOUNTER_CHANCE := 0.25

## Every monster that can spawn in the dungeon
var monsters: Array[GDScript] = [Slime, Mouse, Mimic]


## Returns a new monster for this corridor, or null if nothing spawns
func roll(corridor: Corridor) -> Monster:
	if randf() >= ENCOUNTER_CHANCE:
		return null

	var candidates: Array[Monster] = []
	var weights: Array[float] = []
	for script in monsters:
		var monster: Monster = script.new()
		var weight := monster.get_spawn_chance(corridor)
		if weight > 0.0:
			candidates.append(monster)
			weights.append(weight)

	if candidates.is_empty():
		return null

	var total := 0.0
	for w in weights:
		total += w
	var pick := randf() * total
	for i in candidates.size():
		pick -= weights[i]
		if pick < 0.0:
			return candidates[i]
	return candidates.back()
