class_name Chest
extends RefCounted

const DungeonScript = preload("res://scenes/dungeon/dungeon.gd")
const Corridor = DungeonScript.Corridor

## Chests hide in dead ends too, so you never know if it's a mimic
func get_spawn_chance(corridor: Corridor) -> float:
	if corridor.open_directions.size() == 1:
		return 0.3
	return 0.05
