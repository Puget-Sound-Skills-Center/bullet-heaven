extends Node2D

signal hit_p;


@onready var main = get_node("/root/Main");
@onready var Player = main.get_node("Player");
var goblin_scene := preload("res://Scenes/goblin.tscn");
var bat_scene := preload("res://Scenes/Bat.tscn");
var skeleton_scene := preload("res://Scenes/skeleton.tscn");
var GreenEnemy_scene := preload("res://Scenes/green.tscn");

var time_elapsed := 0.0;
var spawn_rate := 1.0;
var min_spawn_rate := 0.10;
var spawn_acceleration := 0.1;
var max_enemies_per_tick := 6;
var max_alive_enemies := 20;  # tune this based on performance
# How far from the player enemies should spawn
var spawn_distance := 300;

# How many enemies per tick
var enemies_per_tick := 3;

func _process(delta: float) -> void:
	time_elapsed += delta
	# Time in minutes for nicer curves
	var minutes = time_elapsed / 60.0;
	# Spawn rate: starts slow, only gets fast after many minutes
	# 0 min → ~1.4s, 5 min → ~0.9s, 10 min → ~0.6s
	var target_rate = 1.4 - clamp(minutes * 0.06, 0.0, 0.8);
	spawn_rate = lerp(spawn_rate, target_rate, 0.01);
	$Timer.wait_time = spawn_rate;
	# Enemies per tick: grows VERY slowly
	# 0 min → 1, 2 min → 2, 5 min → 3–4, 10 min → 5–6
	var base = 1;
	var growth = pow(max(minutes - 3.0, 0.0), 1.05) * 0.35;
	enemies_per_tick = int(base + growth);
	enemies_per_tick = clamp(enemies_per_tick, 1, max_enemies_per_tick);
	max_alive_enemies = get_alive_cap(minutes);
	update_spawn_caps(minutes);

func get_alive_cap(minutes: float) -> int:
	if minutes < 3.0:
		return 20;
	if minutes < 6.0:
		return 35;
	if minutes < 10.0:
		return 60;
	return 120;

func update_spawn_caps(minutes: float) -> void:
	# Alive cap
	if minutes < 3.0:
		max_alive_enemies = 20;
	elif minutes < 4.0:
		max_alive_enemies = 25
	elif minutes < 6.0:
		max_alive_enemies = 30
	elif minutes < 8.0:
		max_alive_enemies = 40
	elif minutes < 10.0:
		max_alive_enemies = 55
	elif minutes < 12.0:
		max_alive_enemies = 70
	elif minutes < 15.0:
		max_alive_enemies = 90
	else:
		max_alive_enemies = 120;
	# Pre-tick cap (burst size)
	if minutes < 3.0:
		max_enemies_per_tick = 1;
	elif minutes < 6.0:
		max_enemies_per_tick = 2;
	elif minutes < 9.0:
		max_enemies_per_tick = 3;
	elif minutes < 12.0:
		max_enemies_per_tick = 4;
	elif minutes < 15.0:
		max_enemies_per_tick = 5;
	else:
		max_enemies_per_tick = 6;

func can_spawn() -> bool:
	return get_tree().get_nodes_in_group("enemies").size() < max_alive_enemies;

func _on_timer_timeout():
	# Full grace period
	if time_elapsed < 1.0:
		return;
	var _alive = get_tree().get_nodes_in_group("enemies").size();
	var minutes = time_elapsed / 60.0;
	# Minimum density: almost nothing early, ramps over many minutes
	# 0 min → 0, 2 min → 3, 5 min → 8, 10 min → ~15
	var _min_density = int(pow(max(minutes - 5.0, 0.0), 1.2) * 5.0); # always keep at least 10 enemies alive
	_min_density = clamp(_min_density, 0, 60);
	if _alive < _min_density:
			var needed = min(_min_density - _alive, max_alive_enemies - _alive);
			for i in needed:
				if can_spawn():
					spawn_enemy(get_valid_spawn());
	# Main spawn loop
	for i in enemies_per_tick:
		if not can_spawn():
			break;
		spawn_enemy(get_valid_spawn());
	# Random ring spawns (disabled early)
	if minutes > 1.0:
		var roll = randf()
		if roll < 0.25 and can_spawn():
			spawn_enemy(get_valid_spawn())
		elif roll < 0.50 and can_spawn():
			spawn_enemy(get_valid_spawn())
		elif roll < 0.75 and can_spawn():
			spawn_enemy(get_valid_spawn())
		elif can_spawn():
			spawn_enemy(get_valid_spawn())
	 # Far spawns (Only after 7 minutes)
	if minutes > 7.0 and randf() < 0.15 and can_spawn():
		var _far_pos = Player.global_position + Vector2(
			randf_range(-2000, 2000),
			randf_range(-2000, 2000)
	)
		spawn_enemy(_far_pos);

func get_valid_spawn() -> Vector2:
	var pos = get_spawn_position();
	var tries = 0;
	while (is_inside_wall(pos) or is_too_close_to_other_enemies(pos, 250.0)) and tries < 10:
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
	if not can_spawn():
		return;
	var minutes = time_elapsed / 60.0;
	# Pick which enemy to spawn
	var scene := pick_enemy_type(minutes)
	var enemy = scene.instantiate();
	enemy.global_position = spawn_pos;
	# --- HP SCALING ---
	# Base HP comes from the scene (bat=1, goblin=1, skeleton=2, green=1)
	var base_hp = enemy.max_health;
	# Time scaling: +1 HP every ~2 minutes
	var time_hp := int(minutes * 0.5);
	# Level scaling (optional, gentle)
	var level_hp := int(max(main.level - 1, 0) * 0.2);
	# Final HP
	var scaled_hp = base_hp + time_hp + level_hp;
	enemy.max_health = scaled_hp
	enemy.health = scaled_hp
	enemy.hit_player.connect(hit);
	main.add_child(enemy);
	enemy.add_to_group("enemies");
	main.enemies_spawned += 1;

func pick_enemy_type(minutes: float) -> PackedScene:
	# 0-2 minutes: only bats
	if minutes < 2.0:
		return bat_scene;
	# 2-3 minutes: 80% bats, 10% goblins, 10% green
	if minutes < 3.0:
		var roll_early := randf();
		if roll_early < 0.9:
			return bat_scene;
		elif roll_early < 0.8:
			return goblin_scene;
		else:
			return GreenEnemy_scene;
	# 3–5 minutes: 60% bats, 25% goblins, 15% green
	if minutes < 5.0:
		var roll_mid := randf();
		if roll_mid < 0.6:
			return bat_scene;
		elif roll_mid < 0.85:
			return goblin_scene;
		else:
			return GreenEnemy_scene;
	# 5–10 minutes: 40% bats, 40% goblins, 20% green
	if minutes < 10.0:
		var r := randf();
		if r < 0.4:
			return bat_scene;
		elif r < 0.8:
			return goblin_scene;
		elif r < 0.12:
			return GreenEnemy_scene;
		else:
			return skeleton_scene;
	# 10+ minutes: 40% bats, 60% goblins
	var roll_late := randf()
	if roll_late < 0.2:
		return bat_scene;
	elif roll_late < 0.7:
		return goblin_scene;
	elif roll_late < 0.85: 
		return GreenEnemy_scene;
	else:
		return skeleton_scene;

func is_too_close_to_other_enemies(pos: Vector2, min_dist := 200.0) -> bool:
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.global_position.distance_to(pos) < min_dist:
			return true;
	return false;

func hit():
	hit_p.emit();

func _on_ambush_timer_timeout() -> void:
	var _player_pos = Player.global_position;
	var vel = Player.velocity;
	if vel.length() < 1:
		return;
	var _forward = vel.normalized();
	for i in 5:
		if can_spawn():
			spawn_enemy(get_valid_spawn());

func reset_spawner():
	time_elapsed = 0.0;
	spawn_rate = 1.0;
	enemies_per_tick = 1;
	$Timer.wait_time = spawn_rate;
	max_alive_enemies = 120;
