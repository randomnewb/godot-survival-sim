extends CharacterBody2D

@export var speed = 80;

@onready var input_vector = Vector2.ZERO;
@onready var last_direction = "down"
@onready var last_vector = Vector2.ZERO;
@onready var animation
@onready var mining = false

@onready var height = ProjectSettings.get_setting("display/window/size/viewport_height");
@onready var width = ProjectSettings.get_setting("display/window/size/viewport_width");

@onready var player_inventory = preload("res://inventories/player_inventory.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D

@onready var area_hitbox = $AreaHitbox

@onready var operating_system = OS.get_name()

signal pick_up_item
signal dropped_item

func _ready():
	pass;

func _input(event):
	if event.is_action_pressed("drop_item"):
		drop_item(last_vector);
		
func drop_item(last_vector):
	emit_signal("dropped_item", last_vector)

func _process(delta):
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
#	print(operating_system)
	if operating_system == "Android" or operating_system == "iOS":
		if Input.is_action_pressed("tap_left_mouse"):
			var target = get_global_mouse_position() - global_position;
			input_vector = target.normalized();

	returned_direction(input_vector)
		
	if input_vector != Vector2.ZERO:
		last_vector = input_vector
		last_direction = returned_direction(input_vector)
		if not mining:
			animation = "walk_" + str(returned_direction(input_vector))
			animated_sprite_2d.play(animation);
		area_hitbox.position = input_vector * 12;
	elif Input.is_action_just_pressed("ui_accept"):
		# mining action
		if not mining:
			mining = true;
			area_hitbox.monitoring = true;
			animation = "mine_" + str(last_direction)
			animated_sprite_2d.play(animation);
			await get_tree().create_timer(0.85).timeout;
			mining = false;
			area_hitbox.monitoring = false;
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
