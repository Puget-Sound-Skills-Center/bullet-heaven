extends Area2D

@onready var main = get_node("/root/Main");

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
			# Bounce logic
			if main.has_bullet_bounce and randf() < main.bullet_bounce_chance:
				main.spawn_bounce_bullet(body);
			if main.has_explosive_ricochet:
				main.spawn_explosion1(global_position);
				main.screen_shake(0.18, 6);
			body.take_damage(damage);
			queue_free();
