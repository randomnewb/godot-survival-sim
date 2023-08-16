extends Area2D

@onready var parent = get_parent();
@onready var health_component = $"../HealthComponent"

func damage(attack: Attack):
	health_component.health -= attack.attack_damage

	if health_component.health <= 0:
		parent.queue_free()
	
	health_component.taking_damage = true

	parent.velocity = (parent.global_position - attack.attack_position).normalized() * attack.knockback_force
#	await get_tree().create_timer(1.0).timeout;
#	health_component.taking_damage = false;
