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
## Skill points. Strong attacks and heals cost SP, so they can't be spammed.
## Starts full each fight and regains SP_REGEN at the start of each of its turns
var max_sp := 10
var sp := -1 # -1 = not set yet, filled to max_sp on first use
const SP_REGEN := 1

## The monster only spawns once the player is at least this level
var min_player_level := 0
## Chance for a monster's attack to be a critical strike, and how much harder it hits
var crit_chance := 0.08
const CRIT_MIN_MULTIPLIER := 1.2
const CRIT_MAX_MULTIPLIER := 1.4

## How much stronger a monster gets per level it's scaled up (0.15 = +15% of base)
const HP_GROWTH := 0.15
const ATTACK_GROWTH := 0.15
const XP_GROWTH := 0.15

## Spawned monsters are this many levels below or above the player
const MIN_LEVEL_OFFSET := -2
const MAX_LEVEL_OFFSET := 5


## Picks a level near the player's (MIN_LEVEL_OFFSET to MAX_LEVEL_OFFSET,
## never below 1) and scales the monster to it
func scale_to_player_level(player_level: int) -> void:
	scale_to_level(maxi(player_level + randi_range(MIN_LEVEL_OFFSET, MAX_LEVEL_OFFSET), 1))


## Sets the level. Stats grow (or shrink) from the monster's base stats by
## the growth rates for each level above (or below) its base level
func scale_to_level(new_level: int) -> void:
	var bonus := new_level - level
	level = new_level
	if bonus == 0:
		return
	max_hp = maxi(roundi(max_hp * (1.0 + HP_GROWTH * bonus)), 1)
	hp = max_hp
	attack_power = maxi(roundi(attack_power * (1.0 + ATTACK_GROWTH * bonus)), 1)
	xp_reward = maxi(roundi(xp_reward * (1.0 + XP_GROWTH * bonus)), 1)
	for skill in skills:
		if skill is HealSkill:
			skill.amount = maxi(roundi(skill.amount * (1.0 + HP_GROWTH * bonus)), 1)


## How likely this monster is to be the one that spawns in the given corridor,
## compared to the other monsters. 0 means it never spawns there.
func get_spawn_chance(_corridor: Corridor) -> float:
	return 0.0

## Starts the monster's turn: regains a little SP
func regen_sp() -> void:
	if sp < 0:
		sp = max_sp
	sp = mini(sp + SP_REGEN, max_sp)


## Uses a skill, paying its SP cost. Returns the battle log message
func use_skill(skill: Skill, battle: Node) -> String:
	if sp < 0:
		sp = max_sp
	sp = maxi(sp - skill.sp_cost, 0)
	return skill.use(self, battle)


## Picks a usable, affordable skill for this turn, falling back to a plain attack
func choose_skill(battle: Node) -> Skill:
	if sp < 0:
		sp = max_sp
	var usable := skills.filter(func(s: Skill): return s.sp_cost <= sp and s.can_use(self, battle))
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
