extends CharacterBody2D

@export var speed = 80;

@onready var input_vector = Vector2.ZERO;
@onready var last_direction = "down"
@onready var last_vector = Vector2.ZERO;
@onready var animation
@onready var acting = false
@onready var mining_target = null

@onready var height = ProjectSettings.get_setting("display/window/size/viewport_height");
@onready var width = ProjectSettings.get_setting("display/window/size/viewport_width");

@onready var player_inventory = preload("res://inventories/player_inventory.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var area_life_skills_hitbox = $AreaLifeSkillsHitbox
@onready var area_weapon_hitbox = $AreaWeaponHitbox

@onready var operating_system = OS.get_name()

signal pick_up_item
signal dropped_item
signal mined_object (mining_target)
signal health_updated(new_value)
signal attacked
signal player_position_broadcasted(player_position)

func _input(event):
	if event.is_action_pressed("drop_item"):
		emit_signal("dropped_item", last_vector)

func _process(delta):
	emit_signal("player_position_broadcasted", self.global_position)
	
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
		if not acting:
			animation = "walk_" + str(returned_direction(input_vector))
			animated_sprite_2d.play(animation);
			area_life_skills_hitbox.position = input_vector * 12;
			area_weapon_hitbox.position = input_vector * 12
	elif Input.is_action_just_pressed("action_mine"):
		# mining action
		if not acting:
			acting = true;
			area_life_skills_hitbox.monitoring = true;
			animation = "mine_" + str(last_direction)
			animated_sprite_2d.play(animation);
			await get_tree().create_timer(0.1).timeout;
			emit_signal("mined_object", mining_target)
			await get_tree().create_timer(0.75).timeout;
			acting = false;
			area_life_skills_hitbox.monitoring = false;
			mining_target = null;
			emit_signal("mined_object", mining_target)
	elif Input.is_action_just_pressed("action_attack"):
		if not acting:
			acting = true;
			area_weapon_hitbox.monitoring = true;
			animation = "attack_" + str(last_direction)
			animated_sprite_2d.play(animation);
			await get_tree().create_timer(0.1).timeout;
			emit_signal("attacked")
			await get_tree().create_timer(0.10).timeout;
			area_weapon_hitbox.monitoring = false;
			await get_tree().create_timer(0.60).timeout;
			acting = false;
	else:
		if not acting:
			animation = "idle_" + str(last_direction)
			animated_sprite_2d.play(animation);

#	position.x = clamp(position.x, 5, width - 5);
#	position.y = clamp(position.y, 5, height - 5);
	
	#ray_cast code
#	ray_cast_2d.target_position = input_vector * 25;
#	var ray_collide = ray_cast_2d.get_collider()
#	if ray_collide:
#		print("ray: ",ray_collide)

	if not acting:
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


