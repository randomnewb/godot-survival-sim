extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var attack_cooldown_timer = $AttackCooldownTimer
@onready var hitbox_component = $HitboxComponent

var player: CharacterBody2D

var last_direction = "";
var last_attack_direction = "";
var attack_direction = Vector2.ZERO;

@onready var state_machine = $StateMachine

func _physics_process(_delta):
	var state = state_machine.current_state.name
	var new_direction = returned_direction(velocity.normalized())
	
	if new_direction != last_direction:
		last_direction = new_direction

#	Enemy animation is cut off when moving away from player

	match state:
		"EnemyWander", "EnemyFollow":
			var animation = "walk_" + str(last_direction)
			if animated_sprite_2d.animation != animation:
				animated_sprite_2d.play(animation)
			hitbox_component.position = velocity * 40 # Assuming you want to position hitbox 20 units down in these states
		"EnemyIdle":
			var animation = "idle_" + str(last_direction)
			if animated_sprite_2d.animation != animation:
				animated_sprite_2d.play(animation)
		"EnemyAttack":
			if not attack_cooldown_timer.is_stopped():
				return # Don't start a new attack while the cooldown is active
			var animation = "attack_" + str(returned_direction(last_attack_direction.normalized()))
			
			if animated_sprite_2d.animation != animation:
				animated_sprite_2d.play(animation)
		_:
			print("Unhandled state.")
	move_and_collide(velocity)

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

func _on_attack_cooldown_timer_timeout():
	var state = state_machine.current_state.name
	if state == "EnemyAttack":
		animated_sprite_2d.play("attack_" + str(returned_direction(last_attack_direction.normalized()))) # Attack again immediately
	else:
		return

func _on_enemy_attack_facing(direction):
	last_attack_direction = direction
