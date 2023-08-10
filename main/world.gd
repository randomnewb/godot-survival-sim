extends Node

#var BRONZE_DAGGER_SCENE = preload("res://objects/bronze_dagger.tscn")

@onready var player_character = $PlayerCharacter

@onready var player_inventory = $PlayerInventory/CtrlInventory/Inventory
@onready var ctrl_inventory = $PlayerInventory/CtrlInventory
@onready var player_inventory_parent = $PlayerInventory

var inventory_visible = false;

signal item_removed(prototype_id)


func _input(event):
	if event.is_action_pressed("open_inventory"):
		open_inventory();
	if event.is_action_pressed("drop_item"):
		drop_item();

func _ready():
	spawn_interactable("bronze_dagger");
	player_inventory.create_and_add_item("bronze_dagger");

func _process(delta):
	pass;
#	var items: Array = ctrl_inventory.get_selected_inventory_items()
#	if items:
#		player_inventory.remove_child(items[0])
##		print(items[0])
#		spawn_interactable(items[0].prototype_id)

func drop_item():
	var items: Array = ctrl_inventory.get_selected_inventory_items()
	if items:
		player_inventory.remove_child(items[0])
#		print(items[0])
		spawn_interactable(items[0].prototype_id)

func spawn_interactable(item_to_spawn):
	var item_name = item_to_spawn
	var format_path = "res://objects/%s.tscn"
	var actual_path = format_path % item_to_spawn
	var DROP_ITEM_SCENE = load(actual_path)
	var world = get_tree().current_scene;
	item_to_spawn = DROP_ITEM_SCENE.instantiate();
	item_to_spawn.name = item_name
	world.add_child.call_deferred(item_to_spawn, true);
	item_to_spawn.position = player_character.position + Vector2(25, 25);
	
func _on_area_pickup_area_entered(area):
#	print(area.name);
	var regex = RegEx.new()
	regex.compile("^\\w+[a-zA-Z]")
#	print("item name", item_to_spawn)
	var result = regex.search(area.name)
#	if result:
#		print("item is: ", result.get_string());
	var converted_name = result.get_string()
	player_inventory.create_and_add_item(converted_name);
	area.queue_free();

func open_inventory():
	inventory_visible = !inventory_visible
	player_inventory_parent.visible = inventory_visible
