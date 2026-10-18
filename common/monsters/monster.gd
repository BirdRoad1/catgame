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
## Chance to drop an item when beaten. Never more than one (see LootTable)
var drop_chance := 0.5
## What this monster can do on its turn. Picked at random, weighted by Skill.weight
var skills: Array[Skill] = []

## How much stronger a monster gets per level it's scaled up (0.15 = +15% of base)
const HP_GROWTH := 0.15
const ATTACK_GROWTH := 0.15
const XP_GROWTH := 0.15

## Levels the monster up with the player. A monster's base level is what it is
## at player level 1, so the gap between them (and the attack bar speed) stays
## the same while hp, attack, heals and xp grow
func scale_to_player_level(player_level: int) -> void:
	var bonus := maxi(player_level - 1, 0)
	if bonus == 0:
		return
	level += bonus
	max_hp = roundi(max_hp * (1.0 + HP_GROWTH * bonus))
	hp = max_hp
	attack_power = roundi(attack_power * (1.0 + ATTACK_GROWTH * bonus))
	xp_reward = roundi(xp_reward * (1.0 + XP_GROWTH * bonus))
	for skill in skills:
		if skill is HealSkill:
			skill.amount = roundi(skill.amount * (1.0 + HP_GROWTH * bonus))


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
