extends Area2D

@onready var main = get_node("/root/Main");
@export var xp_amount : int = 1;
@export var value := 1;
var pull_speed := 300.0

func _ready() -> void:
	add_to_group("xp_item");

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("Player");
	if player == null:
		return;
	# Magnet logic with Xp
	var dist = global_position.distance_to(player.global_position);
	if dist < player.pickup_radius:
		global_position = global_position.move_toward(player.global_position, pull_speed * delta);

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		main.add_xp(xp_amount);
		main.play_sfx("xp");
		queue_free();
