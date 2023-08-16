extends State
class_name EnemyWander

@export var enemy: CharacterBody2D
@export var move_speed := 0.25
var player: CharacterBody2D

var move_direction: Vector2
var wander_time: float
var idle_chance: float

func randomize_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3);
	idle_chance = randf_range(1, 3);

func enter():
	randomize_wander()

func update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		if idle_chance > 2.5:
			transitioned.emit(self, "EnemyIdle");
		randomize_wander()

func physics_update(_delta: float):
	if enemy:
		enemy.velocity = move_direction * move_speed

	if player != null:
		var direction = player.global_position - enemy.global_position

		if direction.length() < 50:
			transitioned.emit(self, "EnemyFollow");

	else:
		player = get_tree().get_first_node_in_group("Player")
