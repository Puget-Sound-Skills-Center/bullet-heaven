extends Area2D

@export var speed := 500;
@export var damage := 1;
@export var pierce := 0;
var direction := Vector2.ZERO;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += direction * speed * delta;



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage);
		pierce -= 1;
		if pierce < 0:
			queue_free();
