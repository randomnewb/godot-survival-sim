extends Node

@onready var player_inventory = $PlayerInventory/CtrlInventory/Inventory
@onready var ctrl_inventory = $PlayerInventory/CtrlInventory
@onready var player_inventory_parent = $PlayerInventory

@onready var height = ProjectSettings.get_setting("display/window/size/viewport_height");
@onready var width = ProjectSettings.get_setting("display/window/size/viewport_width");

var last_vector = "down"
var inventory_visible = true;

enum Location {
	RANDOM,
	ENVIRONMENT,
	PLAYER,
}

func spawn_interactable(item_to_spawn, location, position, last_vector):
	var item_name = item_to_spawn.to_lower()
	
	var regex = RegEx.new()
	regex.compile("^\\w+[a-zA-Z]")
	var result = regex.search(item_name)
	var converted_name = result.get_string()
	var format_path = "res://objects/%s.tscn"
	var actual_path = format_path % converted_name
	
	var DROP_ITEM_SCENE = load(actual_path)
	
	var world = get_tree().current_scene;
	item_to_spawn = DROP_ITEM_SCENE.instantiate();
	item_to_spawn.name = item_name
	world.add_child.call_deferred(item_to_spawn, true);
	match location:
		Location.RANDOM:
			item_to_spawn.position = get_spawn_position();
		Location.ENVIRONMENT:
			item_to_spawn.position = position
		Location.PLAYER:
			var player_character = world.get_node("PlayerCharacter")
			item_to_spawn.position = player_character.position + (last_vector * 40);

signal item_removed(prototype_id)

func _input(event):
	if event.is_action_pressed("open_inventory"):
		open_inventory();

func get_spawn_position():
	return (Vector2(randi_range(0, width), randi_range(0, height)))

func _ready():
	randomize();
	var world = get_tree().current_scene;
	var PLAYER_SCENE = preload("res://player/player_character.tscn")
	var player = PLAYER_SCENE.instantiate();
	world.add_child.call_deferred(player);
	player.position = player.position + Vector2(100, 100);
	player.pick_up_item.connect(Callable(self,"_on_area_pickup_area_entered"))
	player.dropped_item.connect(Callable(self,"_on_dropped_item"))
	player.mined_object.connect(Callable(self,"_on_mined_item"))
	await get_tree().create_timer(0.85).timeout;
	
	spawn_interactable("bronze_dagger", Location.RANDOM, "", "");
	player_inventory.create_and_add_item("bronze_dagger");

func _process(delta):
	pass;

func _on_dropped_item(last_vector):
	var items: Array = ctrl_inventory.get_selected_inventory_items()
	if items:
		player_inventory.remove_child(items[0])
		spawn_interactable(items[0].prototype_id, Location.PLAYER, "", last_vector)

func _on_mined_item(mining_target):
	var world = get_tree().current_scene;
	if mining_target != null:
		var object = world.find_child(mining_target)
		await get_tree().create_timer(0.40).timeout;
		object.queue_free();
		spawn_interactable(object.name, Location.ENVIRONMENT, object.position, "")

func _on_area_pickup_area_entered(area):
	var regex = RegEx.new()
	regex.compile("^\\w+[a-zA-Z]")
	var result = regex.search(area.name)
	var converted_name = result.get_string()
	player_inventory.create_and_add_item(converted_name);
	await get_tree().create_timer(0.10).timeout;
	area.queue_free();

func open_inventory():
	inventory_visible = !inventory_visible
	player_inventory_parent.visible = inventory_visible
