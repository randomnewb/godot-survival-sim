extends State
class_name Enemy_Idle

@export var enemy: CharacterBody2D
var player: CharacterBody2D

var idle_time: float
var wander_chance: float

func randomize_idle():
	idle_time = randf_range(1, 3)
	wander_chance = randf_range(1, 3)

func enter():
	randomize_idle()

func update(delta: float):
	if idle_time > 0:
		idle_time -= delta
	else:
		if wander_chance > 2.5:
			transitioned.emit(self, "Enemy_Wander");
		randomize_idle()

func physics_update(delta: float):
	if enemy:
		enemy.velocity = Vector2.ZERO;

	if player != null:
		var direction = player.global_position - enemy.global_position

		if direction.length() < 50:
			transitioned.emit(self, "Enemy_Follow");

	else:
		player = get_tree().get_first_node_in_group("Player")
