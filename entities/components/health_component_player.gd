extends HealthComponent

func _ready():
	health = 100.0;
	MAX_HEALTH = 100.0
	health_regen = 1.0;

func _on_regen_timer_timeout():
	health += health_regen;

func _process(_delta):
	if taking_damage:
		taking_damage = false;
