class_name AttackSkill
extends Skill

## Damage is the user's attack_power times this
var power: float
## %s is the user's name, %d is the damage
var message: String


func _init(p_display_name: String, p_power := 1.0, p_weight := 1.0, p_message := "The %s attacks for %d!") -> void:
	super(p_display_name, p_weight)
	power = p_power
	message = p_message


func use(user: Monster, battle: Node) -> String:
	var damage := maxi(roundi(user.attack_power * power), 1)
	if battle.damage_player(damage) == 0:
		return "The %s attacks, but you dodge!" % user.display_name
	return message % [user.display_name, damage]
