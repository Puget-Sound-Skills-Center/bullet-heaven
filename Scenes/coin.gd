extends Area2D

@onready var main = get_node("/root/Main");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play();
	var tween = create_tween();
	scale = Vector2(0.6, 0.6);
	tween.tween_property(self, "scale", Vector2(1,1), 0.15);
	var offset = Vector2(randf_range(-5, 5), randf_range(-5, 5));
	position += offset;
	add_to_group("coins");

func _on_body_entered(body):
	if body.name == "Player":
		main.coins += 1;
		main.update_coins();
	#delete item
	queue_free();
