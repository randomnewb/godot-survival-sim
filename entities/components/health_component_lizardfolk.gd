extends HealthComponent

func _ready():
	health = 40.0;
	MAX_HEALTH = 40.0
	health_regen = 0.5;

func _on_regen_timer_timeout():
	health += health_regen;

func _process(_delta):
	if taking_damage:
		taking_damage = false;
