extends Area2D

@onready var main = get_node("/root/Main");

var speed : int = 500;
var direction : Vector2;
var damage : int = 1;
var pierce_left : int = 0;
var ricochet_left := 0;

var shrapnel_scene := preload("res://Scenes/shrapnel_bullet.tscn");

func _ready() -> void:
	pierce_left = main.bullet_pierce;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if direction == null:
		return;
	position += speed * direction * delta;
	rotation = direction.angle();

func _on_timer_timeout():
	queue_free();

func _on_body_entered(body: Node2D):
	if body.name == "World":
		queue_free();
		return;
	if !body.has_method("take_damage"):
		return;
	# Deal damage
	body.take_damage(damage);
	# Bounce logic
	if main.has_bullet_bounce:
		if main.bounce_timer <= 0:
			main.bounce_timer = main.bounce_cooldown;
			main.spawn_bounce_bullet(body, ricochet_left - 1);
	# Explosive
	if main.bullet_explosive:
		if main.explosive_timer <= 0:
			main.explosive_timer = main.explosive_cooldown;
			main.spawn_explosion1(global_position);
			main.screen_shake(0.18, 6);
	# shrapnel evolution
	if main.bullet_shrapnel:
		if main.shrapnel_timer <= 0:
			main.shrapnel_timer = main.shrapnel_cooldown;
			_spawn_shrapnel();
	# Pierce logic
	if pierce_left > 0:
		pierce_left -= 1;
		return;
	queue_free();

func _spawn_shrapnel():
	for i in range(3):
		var s = shrapnel_scene.instantiate();
		s.global_position = global_position;
		var angle = randf_range(0, TAU);
		s.direction = Vector2.RIGHT.rotated(angle);
		s.damage = max(1, damage / 2);
		main.call_deferred("add_child", s);
