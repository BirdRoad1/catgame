class_name Skill
extends RefCounted

## Something an entity can do on its turn. Subclass this and override use().

var display_name: String
## How likely this skill is to be picked compared to the user's other skills
var weight: float
## SP the user spends to use this. Monsters can't pick skills they can't afford
var sp_cost: int


func _init(p_display_name: String, p_weight := 1.0, p_sp_cost := 0) -> void:
	display_name = p_display_name
	weight = p_weight
	sp_cost = p_sp_cost


## Whether the skill makes sense right now (e.g. no healing at full HP)
func can_use(_user: Monster, _battle: Node) -> bool:
	return true


## Applies the skill and returns the message to show in the battle log
func use(_user: Monster, _battle: Node) -> String:
	return ""
