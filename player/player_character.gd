extends CharacterBody2D

@export var speed = 80;

@onready var input_vector = Vector2.ZERO;
@onready var last_direction = "down"
@onready var animation
@onready var mining = false

@onready var height = ProjectSettings.get_setting("display/window/size/viewport_height");
@onready var width = ProjectSettings.get_setting("display/window/size/viewport_width");

@onready var player_inventory = preload("res://inventories/player_inventory.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D

signal pick_up_item

func _ready():
	pass;

func _process(delta):
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	if Input.is_action_pressed("tap_left_mouse"):
		var target = get_global_mouse_position() - global_position;
		input_vector = target.normalized();

	returned_direction(input_vector)
		
	if input_vector != Vector2.ZERO:
		last_direction = returned_direction(input_vector)
		if not mining:
			animation = "walk_" + str(returned_direction(input_vector))
			animated_sprite_2d.play(animation);
	elif Input.is_action_just_pressed("ui_accept"):
		# mining action
		if not mining:
			mining = true;
			animation = "mine_" + str(last_direction)
			animated_sprite_2d.play(animation);
			await get_tree().create_timer(0.85).timeout;
			mining = false;
	else:
		if not mining:
			animation = "idle_" + str(last_direction)
			animated_sprite_2d.play(animation);

	position.x = clamp(position.x, 5, width - 5);
	position.y = clamp(position.y, 5, height - 5);
	
	#ray_cast code
#	ray_cast_2d.target_position = input_vector * 25;
#	var ray_collide = ray_cast_2d.get_collider()
#	if ray_collide:
#		print("ray: ",ray_collide)
	if not mining:
		move_and_collide(input_vector * speed * delta);

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

func _on_area_pickup_area_entered(area):
	emit_signal("pick_up_item", area);
