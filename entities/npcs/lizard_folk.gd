extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var attack_cooldown_timer = $AttackCooldownTimer
@onready var hitbox_component = $HitboxComponent

var player: CharacterBody2D

var last_direction = "";
var last_attack_direction = Vector2.ZERO;
var player_last_known_pos = Vector2.ZERO
var player_connected = false;

@onready var state_machine = $StateMachine


func _ready():
	pass;

func _on_player_position_changed(player_new_position):
	if player_new_position != player_last_known_pos:
		last_attack_direction = player_new_position - global_position
		player_last_known_pos = player_new_position


func _physics_process(delta):
	player = get_tree().get_first_node_in_group("Player")
	if player != null and not player_connected: 
		print("connected")
		player_connected = true;
		player.player_position_broadcasted.connect(self._on_player_position_changed)
	
	var state = state_machine.current_state.name
	var new_direction = returned_direction(velocity.normalized())
	
	if new_direction != last_direction:
		last_direction = new_direction

	match state:
		"EnemyWander", "EnemyFollow":
			var animation = "walk_" + str(last_direction)
			animated_sprite_2d.play(animation)
		"EnemyIdle":
			var animation = "idle_" + str(last_direction)
			animated_sprite_2d.play(animation)
		"EnemyAttack":
			if not attack_cooldown_timer.is_stopped() and not animated_sprite_2d.is_playing():
				var animation = "attack_" + str(returned_direction(last_attack_direction.normalized()))
				hitbox_component.position = last_attack_direction.normalized() * 1500 * delta
				animated_sprite_2d.play(animation)
				await get_tree().create_timer(0.2).timeout;
				hitbox_component.monitoring = true;
		_:
			print("Unhandled state.")
	move_and_collide(velocity * delta)

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
	hitbox_component.monitoring = false;
