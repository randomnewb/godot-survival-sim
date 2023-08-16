extends Node2D
class_name HealthComponent

@export var MAX_HEALTH := 100.0
@export var health_regen: float = 1.0;
var taking_damage: bool = false;


@onready var health_label = $"../HealthControl/StatLabel"
@onready var health_bar = $"../HealthControl/StatBar"

func _ready():
	health = 1.0;

var health: float = 100.0:
	get:
		return health;
	set(value):
		health = clamp(value, 0, MAX_HEALTH);
		health_label.text = "Health: " + str(health) + "/" + str(MAX_HEALTH)
		health_bar.min_value = 0;
		health_bar.max_value = MAX_HEALTH;
		health_bar.value = health;

func _on_regen_timer_timeout():
	health += health_regen;

func _process(_delta):
	if taking_damage:
		taking_damage = false;
