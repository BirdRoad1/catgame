class_name HealSkill
extends Skill

var amount: int
## %s is the user's name, %d is the HP healed
var message: String


func _init(p_display_name: String, p_amount: int, p_weight := 1.0, p_message := "The %s heals %d HP!") -> void:
	super(p_display_name, p_weight)
	amount = p_amount
	message = p_message


func can_use(user: Monster, _battle: Node) -> bool:
	return user.hp < user.max_hp


func use(user: Monster, _battle: Node) -> String:
	var healed := mini(amount, user.max_hp - user.hp)
	user.hp += healed
	return message % [user.display_name, healed]
