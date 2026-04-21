extends Node2D

signal hit_p;

@onready var main = get_node("/root/Main");
@onready var Player = main.get_node("Player");
var goblin_scene := preload("res://Scenes/goblin.tscn")

# How far from the player enemies should spawn
var spawn_distance := 650

# How many enemies per tick
var enemies_per_tick := 6

func _on_timer_timeout():
	if main.enemies_spawned >= main.max_enemies:
		return;
	var player_pos = Player.global_position;
	for i in enemies_per_tick:
		if main.enemies_spawned >= main.max_enemies:
			break
		var angle = randf() * TAU
		var _offset = Vector2(cos(angle), sin(angle)) * spawn_distance;
		var spawn_pos = player_pos + _offset;
		spawn_enemy(spawn_pos);

func get_front_spawn_position(player_pos, player_vel):
	if player_vel.length() < 1:
		# Player is standing still → spawn randomly around
		var angle = randf() * TAU;
		return player_pos + Vector2(cos(angle), sin (angle)) * spawn_distance;
	# Player is moving → spawn in front
	var forward = player_vel.normalized();
	var angle_offset = randf_range(-1.0, 1.0) #35 degree randomness
	var dir = forward.rotated(angle_offset);
	if Player.velocity.length() > 200:
		enemies_per_tick = 8;
	else:
		enemies_per_tick = 10;
	return player_pos + dir * spawn_distance;

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
