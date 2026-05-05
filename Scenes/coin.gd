extends Area2D

@onready var main = get_node("/root/Main");
var pull_speed := 300.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play();
	var tween = create_tween();
	scale = Vector2(0.6, 0.6);
	tween.tween_property(self, "scale", Vector2(1,1), 0.15);
	var offset = Vector2(randf_range(-5, 5), randf_range(-5, 5));
	position += offset;
	add_to_group("coins");

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("Player");
	if player == null:
		return;
	# Magnet logic with Xp
	var dist = global_position.distance_to(player.global_position);
	if dist < player.pickup_radius:
		global_position = global_position.move_toward(player.global_position, pull_speed * delta);

func _on_body_entered(body):
	if body.name == "Player":
		main.coins += 1;
		main.update_coins();
	#delete item
	queue_free();
