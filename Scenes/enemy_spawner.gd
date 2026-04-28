extends Node2D

signal hit_p;

@onready var main = get_node("/root/Main");
@onready var Player = main.get_node("Player");
var goblin_scene := preload("res://Scenes/goblin.tscn");

var time_elapsed := 0.0
var spawn_rate := 1.0
var min_spawn_rate := 0.15
var spawn_acceleration := 0.01
var max_enemies_per_tick := 40;

# How far from the player enemies should spawn
var spawn_distance := 1200

# How many enemies per tick
var enemies_per_tick := 10

func _process(delta: float) -> void:
	time_elapsed += delta
	# Increase spawn rate over time
	if spawn_rate > min_spawn_rate:
		spawn_rate -= spawn_acceleration * delta;
		$Timer.wait_time = spawn_rate;
	# Curved scaling for enemies per tick
	var growth = pow(time_elapsed / 60.0, 1.3)  # curved growth
	enemies_per_tick = int(5 + growth);
	# Hard cap
	enemies_per_tick = clamp(enemies_per_tick, 5, max_enemies_per_tick);


func _on_timer_timeout():
	var _alive = get_tree().get_nodes_in_group("enemies").size();
	var _min_density = 10 + int(time_elapsed / 20.0); # always keep at least 10 enemies alive
	_min_density = clamp(_min_density, 10, 60);
	if _alive < _min_density:
			var needed = _min_density - _alive;
			for i in needed:
				var pos = get_spawn_position();
				spawn_enemy(pos);
	for i in enemies_per_tick:
		if main.enemies_spawned >= main.get_spawn_cap():
			break;
		spawn_enemy(get_valid_spawn());
	var roll = randf();
	if roll < 0.25:
		spawn_enemy(get_valid_spawn()); # Random ring
	elif roll < 0.50:
		spawn_enemy(get_valid_spawn());
	elif roll < 0.75:
		spawn_enemy(get_valid_spawn());
	else:
		spawn_enemy(get_valid_spawn());
	# Occasionally spawn enemies far away so the world feels full
	if randf() < 0.15:
		var _far_pos = Player.global_position + Vector2(
			randf_range(-2000, 2000),
			randf_range(-2000, 2000)
	)
		spawn_enemy(_far_pos);

func get_valid_spawn() -> Vector2:
	var pos = get_spawn_position();
	var tries = 0;
	while is_inside_wall(pos) and tries < 10:
		pos = get_spawn_position();
		tries += 1;
	return pos;

func is_inside_wall(pos: Vector2) -> bool:
	var tilemap = main.get_node("World") # adjust if needed
	var cell = tilemap.local_to_map(pos)
	return tilemap.get_cell_source_id(0, cell) != -1  # true if tile exists


func get_spawn_position():
	var player_pos = Player.global_position;
	# Spawn distance from player
	var dist = 500;
	# 50% random ring spawn
	if randf() < 0.5:
		var angle = randf() * TAU;
		return player_pos + Vector2(cos(angle), sin(angle)) * dist;
	# 50% spawn in front of player
	var vel = Player.velocity;
	if vel.length() < 1:
		vel = Vector2.RIGHT.rotated(randf() * TAU);
	
	var forward = vel.normalized();
	var offset = forward.rotated(randf_range(-0.5, 0.5)) * dist;
	return player_pos + offset;


func get_front_spawn():
	var _pos = Player.global_position;
	var vel = Player.velocity;
	if vel.length() < 1:
		vel = Vector2.RIGHT.rotated(randf() * TAU);
	var forward = vel.normalized();
	return _pos + forward.rotated(randf_range(-0.4, 0.4)) * spawn_distance;

func get_side_spawn():
	var _pos = Player.global_position;
	var vel = Player.velocity;
	if vel.length() < 1:
		vel = Vector2.RIGHT.rotated(randf() * TAU);
	var _left = vel.normalized().rotated(-PI/2);
	var _right = vel.normalized().rotated(PI/2);
	var _side = _left if randf() < 0.5 else _right;
	return _pos + _side * spawn_distance;

func get_back_spawn():
	var _pos = Player.global_position;
	var vel = Player.velocity;
	if vel.length() < 1:
		vel = Vector2.RIGHT.rotated(randf() * TAU);
	var _back = -vel.normalized();
	return _pos + _back.rotated(randf_range(-0.4, 0.4)) * spawn_distance;

func spawn_enemy(spawn_pos: Vector2) -> void:
	if main.enemies_spawned >= main.get_spawn_cap():
		return;
	var goblin = goblin_scene.instantiate();
	goblin.global_position = spawn_pos;
	goblin.hit_player.connect(hit);
	main.add_child(goblin);
	goblin.add_to_group("enemies");
	goblin.speed += time_elapsed * 0.2;
	main.enemies_spawned += 1;

func hit():
	hit_p.emit();

func _on_ambush_timer_timeout() -> void:
	var player_pos = Player.global_position;
	var vel = Player.velocity;
	if vel.length() < 1:
		return;
	var forward = vel.normalized();
	for i in 5:
		var dir = forward.rotated(randf_range(-0.4, 04));
		var _spawn_pos = player_pos + dir * spawn_distance;
		spawn_enemy(get_valid_spawn());
