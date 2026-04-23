extends Area2D

var speed : int = 500;
var direction : Vector2;
var damage : int = 1;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += speed * direction * delta;


func _on_timer_timeout():
	queue_free();


func _on_body_entered(body: Node2D):
	if body.name == "World":
		queue_free();
	else:
		if body.has_method("take_damage"):
			body.take_damage(damage);
			queue_free();
