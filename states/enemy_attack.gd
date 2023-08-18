extends State
class_name EnemyAttack

@export var enemy: CharacterBody2D;
@onready var attack_cooldown_timer = $"../../AttackCooldownTimer"
var player: CharacterBody2D
var direction = Vector2.ZERO;

signal facing(direction)

func enter():
	player = get_tree().get_first_node_in_group("Player")
	attack_cooldown_timer.start()

func physics_update(_delta: float):
	if player != null:
		direction = player.global_position - enemy.global_position
		emit_signal("facing",direction)
		if direction.length() > 25:
			transitioned.emit(self, "EnemyWander");
			
		else:
			enemy.velocity = Vector2();
			
	else:
		player = get_tree().get_first_node_in_group("Player")

	if player == null:
		transitioned.emit(self, "EnemyWander");
