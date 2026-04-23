extends Node2D

signal hit_p;

@onready var main = get_node("/root/Main");
@onready var Player = main.get_node("Player");
var goblin_scene := preload("res://Scenes/goblin.tscn")

# How far from the player enemies should spawn
var spawn_distance := 950

# How many enemies per tick
var enemies_per_tick := 10

func _on_timer_timeout():
	var _alive = get_tree().get_nodes_in_group("enemies").size();
	var _min_density = 10; # always keep at least 10 enemies alive
	if _alive < _min_density:
			var needed = _min_density - _alive;
			for i in needed:
				var pos = get_spawn_position();
				spawn_enemy(pos);
	for i in enemies_per_tick:
		if main.enemies_spawned >= main.get_spawn_cap():
			break;
	var roll = randf();
	if roll < 0.25:
		spawn_enemy(get_spawn_position()); # Random ring
	elif roll < 0.50:
		spawn_enemy(get_front_spawn());
	elif roll < 0.75:
		spawn_enemy(get_side_spawn());
	else:
		spawn_enemy(get_back_spawn());
	# Occasionally spawn enemies far away so the world feels full
	if randf() < 0.15:
		var _far_pos = Player.global_position + Vector2(
			randf_range(-2000, 2000),
			randf_range(-2000, 2000)
	)
		spawn_enemy(_far_pos);

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
	main.enemies_spawned += 1;

func hit():
	hit_p.emit()

func _on_ambush_timer_timeout() -> void:
	var player_pos = Player.global_position;
	var vel = Player.velocity;
	if vel.length() < 1:
		return;
	var forward = vel.normalized();
	for i in 5:
		var dir = forward.rotated(randf_range(-0.4, 04));
		var spawn_pos = player_pos + dir * spawn_distance;
		spawn_enemy(spawn_pos);
