extends Area2D

var speed = 50;
var player_closeby = false;
var body_node = "";

func _process(delta):
	if player_closeby:
		self.position = self.position.move_toward(body_node.position, speed * delta);

func _on_pickup_zone_body_entered(body):
	body_node = body;
	player_closeby = true;

func _on_pickup_zone_body_exited(_body):
	player_closeby = false;
