extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

var last_direction = "up";
var attacking: bool = false;

func _physics_process(_delta):
	move_and_collide(velocity)
	
	if velocity.length() > 0 and not attacking:
		last_direction = returned_direction(velocity)
		var animation = "walk_" + str(returned_direction(velocity.normalized()))
		animated_sprite_2d.play(animation);
	elif attacking:
#		Enemy switches animation direction while attacking if player moves 
		last_direction = returned_direction(velocity)
		var animation = "attack_" + str(returned_direction(velocity.normalized()))
		animated_sprite_2d.play(animation);
		await get_tree().create_timer(0.80).timeout;
		attacking = false;
	else:
		var animation = "idle_" + str(last_direction)
		animated_sprite_2d.play(animation);

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

func _on_enemy_attack_attacked():
	attacking = true
