extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

var last_direction = "up";

func _physics_process(_delta):
	move_and_slide();

	if velocity.length() > 0:
		last_direction = returned_direction(velocity)
		var animation = "walk_" + str(returned_direction(velocity.normalized()))
		animated_sprite_2d.play(animation);
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
