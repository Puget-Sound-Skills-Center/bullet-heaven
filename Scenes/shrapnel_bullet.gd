extends Area2D

@onready var main = get_node("/root/Main")

var speed := 650
var direction := Vector2.ZERO
var damage := 1

func _process(delta: float) -> void:
	position += speed * direction * delta;

func _on_body_entered(body: Node2D) -> void:
	if body.name == "World":
		queue_free();
		return;
	if body.has_method("take_damage"):
		body.take_damage(damage);
		queue_free();
