extends State
class_name EnemyAttack

@export var enemy: CharacterBody2D;
var player: CharacterBody2D
var direction = Vector2.ZERO;

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"
@onready var attack_cooldown_timer = $"../../AttackCooldownTimer"

var animation_finished: bool = false;

signal facing(direction)

func enter():
	player = get_tree().get_first_node_in_group("Player")
	animation_finished = false;
	attack_cooldown_timer.start()
	animated_sprite_2d.stop()

func physics_update(_delta: float):
	if player != null:
		direction = player.global_position - enemy.global_position
		emit_signal("facing",direction)

		if direction.length() > 20 and animation_finished:
			transitioned.emit(self, "EnemyFollow");
			attack_cooldown_timer.stop()
			
		else:
			enemy.velocity = Vector2();
			
	else:
		player = get_tree().get_first_node_in_group("Player")

	if player == null:
		transitioned.emit(self, "EnemyWander");

func _on_animated_sprite_2d_animation_looped():
	animation_finished = true


func _on_animated_sprite_2d_animation_finished():
#	animation_finished = true
	pass;
