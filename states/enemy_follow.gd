extends State
class_name Enemy_Follow

@export var enemy: CharacterBody2D;
@export var move_speed := 20.0
var player: CharacterBody2D

func enter():
	player = get_tree().get_first_node_in_group("Player")

func physics_update(_delta: float):
	if player != null:
		var direction = player.global_position - enemy.global_position
	
		if direction.length() > 10:
			enemy.velocity = direction.normalized() * move_speed
		else:
			enemy.velocity = Vector2();
			
		if direction.length() > 100:
			transitioned.emit(self, "Enemy_Wander");
			
	else:
		player = get_tree().get_first_node_in_group("Player")
