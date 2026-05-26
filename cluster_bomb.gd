extends Area2D

@onready var main = get_node("/root/Main");

var explosion_delay := 0.3;
var exploded := false;

func _ready():
	await get_tree().create_timer(explosion_delay).timeout;
	_explode();

func _explode():
	if exploded:
		return;
	exploded = true;
	main.spawn_explosion2(global_position);
	# Spawn micro missiles in random directions
	var micro_scene = preload("res://micro_missile.tscn");
	for i in range(5):
		var m = micro_scene.instantiate();
		m.global_position = global_position;
		var dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized();
		m.direction = dir;
		main.call_deferred("add_child", m);
	queue_free();
