extends State
class_name EnemyAttack

@export var enemy: CharacterBody2D;
var player: CharacterBody2D

var finished_attacking: bool = false;

var direction = Vector2.ZERO;

signal attacked(direction)

func enter():
	player = get_tree().get_first_node_in_group("Player")
	emit_signal("attacked", direction)

func physics_update(_delta: float):
	if player != null:
		direction = player.global_position - enemy.global_position

		if finished_attacking == true:
			finished_attacking = false;
			emit_signal("attacked", direction)

		if direction.length() > 25:
			transitioned.emit(self, "EnemyWander");
			
		else:
			enemy.velocity = Vector2();
			
	else:
		player = get_tree().get_first_node_in_group("Player")

	if player == null:
		transitioned.emit(self, "EnemyWander");


func _on_lizard_folk_attack_finished():
	finished_attacking = true
