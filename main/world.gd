extends Node

@onready var player_inventory = $PlayerInventory/CtrlInventory/Inventory
@onready var ctrl_inventory = $PlayerInventory/CtrlInventory
@onready var player_inventory_parent = $PlayerInventory

#var last_vector = "down"
var inventory_visible = true;

#signal item_removed(prototype_id)

func _input(event):
	if event.is_action_pressed("open_inventory"):
		open_inventory();

func _ready():
	Spawn.spawn_player();
	
	await get_tree().create_timer(0.85).timeout;
	Spawn.spawn_interactable("bronze_dagger", Spawn.Location.RANDOM, "", "");
	
#	Adding item to player inventory example
	player_inventory.create_and_add_item("bronze_dagger");

func _process(_delta):
	pass;

func _on_dropped_item(last_vector):
	var items: Array = ctrl_inventory.get_selected_inventory_items()
	if items:
		player_inventory.remove_child(items[0])
		Spawn.spawn_interactable(items[0].prototype_id, Spawn.Location.PLAYER, "", last_vector)

func _on_mined_item(mining_target):
	var world = get_tree().current_scene;
	if mining_target != null:
		var object = world.find_child(mining_target)
		await get_tree().create_timer(0.40).timeout;
		object.queue_free();
		Spawn.spawn_interactable(object.name, Spawn.Location.ENVIRONMENT, object.position, "")

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
