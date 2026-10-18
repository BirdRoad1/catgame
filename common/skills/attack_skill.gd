class_name AttackSkill
extends Skill

## Damage is the user's attack_power times this
var power: float
## %s is the user's name, %d is the damage
var message: String


func _init(p_display_name: String, p_power := 1.0, p_weight := 1.0, p_message := "The %s attacks for %d!", p_sp_cost := 0) -> void:
	super(p_display_name, p_weight, p_sp_cost)
	power = p_power
	message = p_message


func use(user: Monster, battle: Node) -> String:
	var multiplier := power
	var crit := randf() < user.crit_chance
	if crit:
		multiplier *= randf_range(Monster.CRIT_MIN_MULTIPLIER, Monster.CRIT_MAX_MULTIPLIER)
	var damage := maxi(roundi(user.attack_power * multiplier), 1)
	if battle.damage_player(damage) == 0:
		return "The %s attacks, but you dodge!" % user.display_name
	if crit:
		return "Critical strike! " + message % [user.display_name, damage]
	return message % [user.display_name, damage]
