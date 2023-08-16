extends Area2D

@export var attack_damage := 25.0
@export var knockback_force := 1000.0
@export var stun_time := 1.5

func _on_area_entered(area):
	print("attack hits: ", area)
	if area.has_method("damage"):
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.knockback_force = knockback_force
		attack.attack_position = get_parent().global_position
		attack.stun_time = stun_time
		area.damage(attack)
