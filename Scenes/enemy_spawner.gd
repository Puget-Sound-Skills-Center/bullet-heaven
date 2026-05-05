extends Node2D

signal hit_p;

# Enemy Types
var goblin_small := preload("res://Scenes/goblin_Small.tscn");
var goblin_normal := preload("res://Scenes/goblin.tscn");
var goblin_big := preload("res://Scenes/goblin_Big.tscn");


@onready var main = get_node("/root/Main");
@onready var Player = main.get_node("Player");
var goblin_scene := preload("res://Scenes/goblin.tscn");

var time_elapsed := 0.0;
var spawn_rate := 1.0;
var min_spawn_rate := 0.10;
var spawn_acceleration := 0.001;
var max_enemies_per_tick := 20;
var max_alive_enemies := 120;  # tune this based on performance
# How far from the player enemies should spawn
var spawn_distance := 12000;

# How many enemies per tick
var enemies_per_tick := 10;

func _process(delta: float) -> void:
	time_elapsed += delta
	# Time in minutes for nicer curves
	var minutes = time_elapsed / 60.0;
	# Spawn rate: starts slow, only gets fast after many minutes
	# 0 min → ~1.4s, 5 min → ~0.9s, 10 min → ~0.6s
	var target_rate = 1.74 - clamp(minutes * 0.01, 0.0, 0.6);
	spawn_rate = lerp(spawn_rate, target_rate, 0.02);
	$Timer.wait_time = spawn_rate;
	# Enemies per tick: grows VERY slowly
	# 0 min → 1, 2 min → 2, 5 min → 3–4, 10 min → 5–6
	var base = 1;
	var growth = pow(max(minutes - 3.0, 0.0), 2.0) * 0.55;
	enemies_per_tick = int(base + growth);
	enemies_per_tick = clamp(enemies_per_tick, 1, max_enemies_per_tick);

func can_spawn() -> bool:
	return get_tree().get_nodes_in_group("enemies").size() < max_alive_enemies;

func pick_enemy(minutes: float) -> PackedScene:
	if minutes < 3.0:
		return goblin_small;
	if minutes < 7.0:
		var roll = randf();
		if roll < 0.6:
			return goblin_small;
		else:
			return goblin_normal;
		# Late game
	var roll = randf()
	if roll < 0.5:
		return goblin_normal;
	else:
		return goblin_big;

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
	var goblin = goblin_scene.instantiate();
	goblin.global_position = spawn_pos;
	var minutes = time_elapsed / 60.0;
	var level = main.level;
	var _player_damage = main.player.stats.damage;
	var _player_speed = main.player.stats.move_speed;
	# --- HP SCALING ---
	# Base 1 HP, +1 HP every 3 levels, +soft time scaling
	var base_hp := 1
	var level_hp := int(max(level - 1, 0) / 3) # +1 HP per 3 levels
	var time_hp := int(minutes * 0.4) # +1 HP every ~2.5 min
	var scaled_hp := base_hp + level_hp + time_hp
	goblin.max_health = clamp(scaled_hp, 1, 200);
	goblin.health = goblin.max_health;
	# --- ELITES CHANCE ---
	goblin.hit_player.connect(hit);
	main.add_child(goblin);
	goblin.add_to_group("enemies");
	main.enemies_spawned += 1;

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
