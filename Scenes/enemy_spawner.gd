extends Node2D

signal hit_p;

@onready var main = get_node("/root/Main");
@onready var Player = main.get_node("Player");
var goblin_scene := preload("res://Scenes/goblin.tscn")

# How far from the player enemies should spawn
var spawn_distance := 50

# How many enemies per tick
var enemies_per_tick := 6

func _on_timer_timeout():
	if main.enemies_spawned >= main.get_spawn_cap():
		return;
	var t = main.run_time;
	# Start slow, get faster
	if t < 30:
		enemies_per_tick = 1;
	elif t < 60:
		enemies_per_tick = 2;
	elif t < 120:
		enemies_per_tick = 4;
	elif t < 180:
		enemies_per_tick = 6;
	else:
		enemies_per_tick = 10;

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

func spawn_enemy(spawn_pos: Vector2) -> void:
	if main.enemies_spawned >= main.max_enemies:
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
