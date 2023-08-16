class_name Attack

var attack_damage: float
var knockback_force: float
var attack_position: Vector2
var stun_time: float

func print_damage():
	print("Attacking for " + str(attack_damage))
