extends CharacterBody2D

@export var speed = 80;

@onready var input_vector = Vector2.ZERO;
@onready var last_direction = "down"
@onready var last_vector = Vector2.ZERO;
@onready var animation
@onready var mining = false
@onready var mining_target = null

@onready var height = ProjectSettings.get_setting("display/window/size/viewport_height");
@onready var width = ProjectSettings.get_setting("display/window/size/viewport_width");

@onready var player_inventory = preload("res://inventories/player_inventory.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var area_life_skills_hitbox = $AreaLifeSkillsHitbox

@onready var health_label = $HealthControl/StatLabel
@onready var health_bar = $HealthControl/StatBar

@onready var operating_system = OS.get_name()

signal pick_up_item
signal dropped_item
signal mined_object (mining_target)
signal health_updated(new_value)

@export var health_regen: float = 1.0;
@export var max_health: float = 100.0;
@export var health: float = 100.0:
	get:
		return health;
	set(value):
		health = clamp(value, 0, 100);
		health_label.text = "Health: " + str(health) + "/" + str(max_health)
		health_bar.min_value = 0;
		health_bar.max_value = max_health;
		health_bar.value = health;
		emit_signal("health_updated", health)

func _ready():
	health = 1.0;

func _input(event):
	if event.is_action_pressed("drop_item"):
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
			area_life_skills_hitbox.position = input_vector * 12;
	elif Input.is_action_just_pressed("ui_accept"):
		# mining action
		if not mining:
			mining = true;
			area_life_skills_hitbox.monitoring = true;
			animation = "mine_" + str(last_direction)
			animated_sprite_2d.play(animation);
			await get_tree().create_timer(0.1).timeout;
			emit_signal("mined_object", mining_target)
			await get_tree().create_timer(0.75).timeout;
			mining = false;
			area_life_skills_hitbox.monitoring = false;
			mining_target = null;
			emit_signal("mined_object", mining_target)
			
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

func _on_area_life_skills_hitbox_body_entered(body):
	if body:
		mining_target = body.name;

func _on_regen_timer_timeout():
	health += health_regen;



