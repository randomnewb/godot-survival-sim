extends Node

var BRONZE_DAGGER_SCENE = preload("res://objects/bronze_dagger.tscn")

@onready var player_inventory = $PlayerInventory/CtrlInventory/Inventory

func _ready():
	spawn_interactable();
	player_inventory.create_and_add_item("bronze_dagger");

func spawn_interactable():
	var bronze_dagger = BRONZE_DAGGER_SCENE.instantiate();
	var world = get_tree().current_scene;
	world.add_child.call_deferred(bronze_dagger);
	bronze_dagger.position.x = 50.0;
	bronze_dagger.position.y = 50.0;


func _on_area_pickup_area_entered(area):
	player_inventory.create_and_add_item(area.name);
	area.queue_free();
