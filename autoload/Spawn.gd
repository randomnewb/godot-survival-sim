extends Node

@onready var height = ProjectSettings.get_setting("display/window/size/viewport_height");
@onready var width = ProjectSettings.get_setting("display/window/size/viewport_width");

enum Location {
	RANDOM,
	ENVIRONMENT,
	PLAYER,
}

func get_room_spawn_position():
	return (Vector2(randi_range(0, width), randi_range(0, height)))

func spawn_interactable(item_to_spawn, location, position, last_vector):
	randomize();
#	Standardize item name
	var item_name = item_to_spawn.to_lower()

#	Parse incoming Godot Node, chop off trailing numbers
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
			item_to_spawn.position = get_room_spawn_position()
		Location.ENVIRONMENT:
			item_to_spawn.position = position
		Location.PLAYER:
			var player_character = world.get_node("PlayerCharacter")
			item_to_spawn.position = player_character.position + (last_vector * 40);

func spawn_player():
	var world = get_tree().current_scene;
	var PLAYER_SCENE = preload("res://player/player_character.tscn")
	var player = PLAYER_SCENE.instantiate();
	world.add_child.call_deferred(player);
	player.position = player.position + Vector2(100, 100);
	player.pick_up_item.connect(Callable(world,"_on_area_pickup_area_entered"))
	player.dropped_item.connect(Callable(world,"_on_dropped_item"))
	player.mined_object.connect(Callable(world,"_on_mined_item"))
