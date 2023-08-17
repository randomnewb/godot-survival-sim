extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var attack_cooldown_timer = $AttackCooldownTimer
@onready var hitbox_component = $HitboxComponent

var player: CharacterBody2D

var last_direction = "up";
var attacking: bool = false;
var attack_direction = Vector2.ZERO;

@onready var state_machine = $StateMachine

signal attack_finished

func _physics_process(_delta):

#	Enemy only attacks once

	if velocity.length() > 0 and not attacking:
		last_direction = returned_direction(velocity)
		var animation = "walk_" + str(returned_direction(velocity.normalized()))
		animated_sprite_2d.play(animation);
		hitbox_component.position = velocity * 40
	elif attacking:
		last_direction = returned_direction(velocity)
		var animation = "attack_" + str(returned_direction(velocity.normalized()))
		animated_sprite_2d.play(animation);
		await get_tree().create_timer(0.80).timeout;
		attacking = false;
	else:
		var animation = "idle_" + str(last_direction)
		animated_sprite_2d.play(animation);

	move_and_collide(velocity)
#	match state_machine.current_state.name:
#		EnemyWander:
#			if velocity.length() > 0:
#				var animation = "walk_" + str(returned_direction(velocity.normalized()))
#				animated_sprite_2d.play(animation);
#				hitbox_component.position = velocity.normalized() * 20;
#		EnemyIdle:
#			var animation = "idle_" + str(last_direction)
#			animated_sprite_2d.play(animation);
#		EnemyAttack:
#			var animation = "attack_" + str(returned_direction(attack_direction))
#			animated_sprite_2d.play(animation);
#		EnemyFollow:
#			var animation = "walk_" + str(returned_direction(velocity.normalized()))
#			animated_sprite_2d.play(animation);
#			hitbox_component.position = velocity.normalized() * 20;
	
func returned_direction(vector: Vector2):
	if abs(vector.x) > abs(vector.y):
		if vector.x < 0.0:
			return "left"
		else:
			return "right"
	else:
		if vector.y < 0.0:
			return "up";
		else:
			return "down";

func _on_enemy_attack_attacked(direction):
	if attack_cooldown_timer.is_stopped():
		attack_cooldown_timer.start()
		attack_direction = direction
		attacking = true;
		hitbox_component.monitoring = attacking;

func _on_attack_cooldown_timer_timeout():
	attack_cooldown_timer.stop();
	player = get_tree().get_first_node_in_group("Player")
	if player == null:
		attacking = false;
		hitbox_component.monitoring = attacking;
	else:
		pass;
		
