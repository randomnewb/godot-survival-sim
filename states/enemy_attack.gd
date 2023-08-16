extends State
class_name EnemyAttack

@export var enemy: CharacterBody2D;
var player: CharacterBody2D

signal attacked

func enter():
	player = get_tree().get_first_node_in_group("Player")
	emit_signal("attacked")

func physics_update(_delta: float):
#	Bug: Enemy only attacks once
	
	if player != null:
		var direction = player.global_position - enemy.global_position

		if direction.length() > 50:
			transitioned.emit(self, "EnemyWander");
			
	else:
		player = get_tree().get_first_node_in_group("Player")
