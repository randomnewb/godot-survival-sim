extends Node2D
class_name HealthComponent

@export var MAX_HEALTH := 100.0
var health: float
var taking_damage: bool = false;

func _ready():
	health = MAX_HEALTH

func _process(_delta):
	if taking_damage:
		taking_damage = false;

#func damage(attack: Attack):
#	health -= attack.attack_damage
#
#	if health <= 0:
#		get_parent().queue_free()
#
#	taking_damage = false;
