class_name Monster
extends RefCounted

const DungeonScript = preload("res://scenes/dungeon/dungeon.gd")
const Corridor = DungeonScript.Corridor

var display_name: String
## Monsters above the player's level make the attack bar faster
var level := 1
var texture: Texture2D
var max_hp: int
var hp: int
var attack_power: int
## XP the player gets for beating it
var xp_reward: int
## What this monster can do on its turn. Picked at random, weighted by Skill.weight
var skills: Array[Skill] = []

## How likely this monster is to be the one that spawns in the given corridor,
## compared to the other monsters. 0 means it never spawns there.
func get_spawn_chance(_corridor: Corridor) -> float:
	return 0.0

## Picks a usable skill for this turn, falling back to a plain attack
func choose_skill(battle: Node) -> Skill:
	var usable := skills.filter(func(s: Skill): return s.can_use(self, battle))
	if usable.is_empty():
		return AttackSkill.new("Attack")

	var total := 0.0
	for s in usable:
		total += s.weight
	var roll := randf() * total
	for s in usable:
		roll -= s.weight
		if roll < 0.0:
			return s
	return usable.back()
