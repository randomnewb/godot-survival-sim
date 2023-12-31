extends State
class_name EnemyFollow

@export var enemy: CharacterBody2D;
@export var move_speed := 27.0
var player: CharacterBody2D

func enter():
	player = get_tree().get_first_node_in_group("Player")

func physics_update(_delta: float):
	if player != null:
		var direction = player.global_position - enemy.global_position
	
		if direction.length() > 10:
			enemy.velocity = direction.normalized() * move_speed
			
			if direction.length() < 25:
				transitioned.emit(self, "EnemyAttack");
			
		else:
			enemy.velocity = Vector2();
			
		if direction.length() > 100:
			transitioned.emit(self, "EnemyWander");
			
	else:
		player = get_tree().get_first_node_in_group("Player")
