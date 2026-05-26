extends Node
@onready var player = get_node("Player");

var run_time := 0.0;
var wave : int;
var difficulty : float;
const DIFF_MULTIPLIER : float = 1.2;
var enemies_killed := 0;
var max_enemies : int
var lives : int;
var enemies_spawned : int;
var xp : int = 0
var xp_to_level : int = 10   # adjust as you like
var level : int = 1
var coins: int = 0;
var reroll_cost := 10;
const OrbitGun = preload("res://OrbitGun.gd");
var lightning_damage := 5;
var lightning_chain := 0;       # 0 = no chain
var auto_strike_timer := 2.0;
var acid_dropper = null;

var has_orbit_blade := false;
var has_orbit_gun := false;
var has_aoe_aura := false;
var has_lightning := false;
var has_bullet_bounce := false;
var has_explosive_ricochet := false;
var has_homing_missile := false;
var homing_missile_chance := 0.20;

var shake_time := 0.0;
var shake_duration := 0.0;
var shake_strength := 0.0;
var cam = null;

# Lightning evolution
var lightning_level := 0;
var lightning_aoe := false;
var lightning_auto_strike := false;
var lightning_cooldown := 2.0;
var lightning_timer := 0.0;

# Missile evolution
var missile_level := 0;
var missile_split := false;
var missile_cluster := false;
var missile_armageddon := false;
var missile_cooldown := 4.0;
var missile_timer := 0.0;

# Bullet evolution
var bullet_level := 0;
var bullet_pierce := 0;
var bullet_explosive := false;
var bullet_ricochet := 0;
var bullet_shrapnel := false;
var explosive_cooldown := 0.0;
var explosive_timer := 0.0;
var bounce_cooldown := 1.0;
var bounce_timer := 0.0;
var shrapnel_cooldown := 1.5;
var shrapnel_timer := 0.0;

# Aura evolution
var aura_level := 0
var aura_radius := 50
var aura_dot := false
var aura_pulse := false

var orbit_gun_sprites = [
	preload("res://Weapons/GunPack/Pack 1/1px/25.png"),
	preload("res://Weapons/GunPack/Pack 1/1px/26.png"),
	preload("res://Weapons/GunPack/Pack 1/1px/28.png"),
	preload("res://Weapons/GunPack/Pack 1/1px/31.png")
]

var weapon_offsets = [
	Vector2(40, -55),  # right shoulder
	Vector2(-40, -45), # left shoulder
	Vector2(0, -35),   # above head
	Vector2(0, 20),    # above head
	Vector2(30, 0),    # right side
	Vector2(-30, 0)    # left side
]
var weapon_count := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game();
	cam = get_node("Player/Camera2D");
	$CanvasLayer/GameOver/Button.pressed.connect(reset_run);

func new_game():
	wave = 1;
	lives = 3;
	difficulty = 10.0;
	$EnemySpawner/Timer.wait_time = 1.0;
	reset();

func reset():
	var map_size = Vector2(3264, 2255);
	var center = map_size / 2
	$Player.global_position = center;
	xp = 0;
	level = 1;
	reroll_cost = 10;
	update_level_text();
	xp_to_level = 10;
	update_xp_bar();
	max_enemies = int(difficulty);
	enemies_spawned = 0;
	lives = 50;
	run_time = 0.0;
	enemies_killed = 0;
	coins = 0;
	$Player.reset();
	$Player.reset_stats();
	$Player.clear_weapon();
	weapon_count = 0;
	acid_dropper = null;
	has_orbit_blade = false;
	has_orbit_gun = false;
	has_aoe_aura = false;
	aura_level = 0;
	aura_radius = 50;
	aura_dot = false;
	aura_pulse = false;
	has_lightning = false;
	lightning_level = 0;
	lightning_damage = 15;
	lightning_chain = 0;
	lightning_aoe = false;
	lightning_auto_strike = false;
	has_bullet_bounce = false;
	bullet_explosive = false;
	bullet_shrapnel = false;
	bullet_pierce = 0;
	has_homing_missile = false;
	missile_level = 0;
	homing_missile_chance = 0.20;
	missile_split = false;
	missile_cluster = false;
	missile_armageddon = false;
	$UpgradeManager.reset();
	get_tree().call_group("enemies", "queue_free");
	get_tree().call_group("bullets", "queue_free");
	get_tree().call_group("items", "queue_free");
	$CanvasLayer/HUD/LivesLabel.text = "X " + str(lives);
	$CanvasLayer/HUD/WaveLabel.text = "WAVE: " + str(wave);
	$CanvasLayer/HUD/EnemyLabel.text = "X " + str(max_enemies);
	$CanvasLayer/GameOver.hide();
	get_tree().paused = true;
	$RestartTimer.start();

func reset_run():
	# Full reset because the player died
	wave = 1;
	difficulty = 30.0;
	max_enemies = int(difficulty);
	enemies_spawned = 0;
	xp = 0;
	level = 1;
	reroll_cost = 10;
	xp_to_level = 10;
	update_xp_bar();
	update_level_text();
	lives = 50;
	run_time = 0.0;
	enemies_killed = 0;
	coins = 0;
	$CanvasLayer/HUD/LivesLabel.text = "X " + str(lives)
	$Player.reset();
	$Player.reset_stats();
	$Player.clear_weapon();
	weapon_count = 0;
	acid_dropper = null;
	has_orbit_blade = false;
	has_orbit_gun = false;
	has_aoe_aura = false;
	aura_level = 0;
	aura_radius = 50;
	aura_dot = false;
	aura_pulse = false;
	has_lightning = false;
	lightning_level = 0;
	lightning_damage = 15;
	lightning_chain = 0;
	lightning_aoe = false;
	lightning_auto_strike = false;
	has_bullet_bounce = false;
	bullet_explosive = false;
	bullet_shrapnel = false;
	bullet_pierce = 0;
	has_homing_missile = false;
	missile_level = 0;
	homing_missile_chance = 0.20;
	missile_split = false;
	missile_cluster = false;
	missile_armageddon = false;
	$UpgradeManager.reset();
	get_tree().call_group("enemies", "queue_free");
	get_tree().call_group("bullets", "queue_free");
	get_tree().call_group("coins", "queue_free");
	get_tree().call_group("xp_item", "queue_free");
	$EnemySpawner.reset_spawner();
	$CanvasLayer/HUD/WaveLabel.text = "WAVE: " + str(wave);
	$CanvasLayer/HUD/EnemyLabel.text = "X " + str(max_enemies);
	$CanvasLayer/GameOver.hide();
	get_tree().paused = false;

func reset_wave():
	wave += 1;
	difficulty *= DIFF_MULTIPLIER;
	max_enemies = int(difficulty);
	enemies_spawned = 0;
	$CanvasLayer/HUD/WaveLabel.text = "WAVE: " + str(wave);
	$CanvasLayer/HUD/EnemyLabel.text = "X " + str(max_enemies);
	get_tree().call_group("enemies", "queue_tree");
	get_tree().call_group("xp_item", "queue_tree");
	get_tree().paused = false;

func screen_shake(duration: float, strength: float):
	shake_duration = duration;
	shake_time = duration;
	shake_strength = strength;

func update_xp_bar():
	var ratio = float(xp) / float(xp_to_level);
	ratio = clamp(ratio, 0.0, 1.0);
	var full_width = $CanvasLayer/XPBar/BackgroundPanelBackgroundPanelBackgroundPanelBackgroundPanel.size.x;
	$CanvasLayer/XPBar/FillPanel.size.x = full_width * ratio;

func add_xp(amount: int):
	xp += amount;
	update_xp_bar();
	while xp >= xp_to_level:
		xp -= xp_to_level;
		level += 1;
		xp_to_level = int(xp_to_level * 1.25);
		update_xp_bar();
		update_level_text();
		show_level_up_choices();

func update_level_text():
	$CanvasLayer/XPBar/LevelLabel.text = "Lv " + str(level);

func show_level_up_choices():
	get_tree().paused = true;
	$CanvasLayer/LevelUpPanel.show();
	$CanvasLayer/LevelUpPanel/RerollButton.disabled = coins < 10;
	$CanvasLayer/LevelUpPanel/RerollButton.text = "Reroll (-" + str(reroll_cost) + " Coins)";
	$CanvasLayer/LevelUpPanel/RerollButton.disabled = coins < reroll_cost;
	var choices = $UpgradeManager.get_random_upgrades(self);
	
	$CanvasLayer/LevelUpPanel/Option1.text = choices[0].name;
	$CanvasLayer/LevelUpPanel/Option2.text = choices[1].name;
	$CanvasLayer/LevelUpPanel/Option3.text = choices[2].name;
	
	$CanvasLayer/LevelUpPanel/Option1/Icon.texture = choices[0].icon;
	$CanvasLayer/LevelUpPanel/Option2/Icon.texture = choices[1].icon;
	$CanvasLayer/LevelUpPanel/Option3/Icon.texture = choices[2].icon;
	
	$CanvasLayer/LevelUpPanel/Option1/DescLabel.text = choices[0].description;
	$CanvasLayer/LevelUpPanel/Option2/DescLabel.text = choices[1].description;
	$CanvasLayer/LevelUpPanel/Option3/DescLabel.text = choices[2].description;

func close_level_up_panel():
	$CanvasLayer/LevelUpPanel.hide();
	get_tree().paused = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !get_tree().paused:
		run_time += _delta;
		update_timer_display();
	if acid_dropper != null:
		acid_dropper.tick(_delta, $Player.global_position, self);
	if shake_time > 0:
		shake_time -= _delta;
		var t = shake_time / shake_duration;
		var intensity = shake_strength * t * t; # Smooth falloff
		cam.offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
	else:
		cam.offset = Vector2.ZERO;
	if has_lightning:
		lightning_timer -= _delta;
		if lightning_timer <= 0:
			lightning_timer = lightning_cooldown;
			trigger_lightning();
	if has_homing_missile:
		missile_timer -= _delta;
		if missile_timer <= 0:
			missile_timer = missile_cooldown;
			spawn_homing_missile();
	if has_bullet_bounce:
		bounce_timer -= _delta;
	if bullet_explosive:
		explosive_timer -= _delta;

func update_timer_display():
	var minutes = int(run_time) / 60.0;
	var seconds = int(run_time) % 60;
	$CanvasLayer/HUD/TimerLabel.text = "%02d:%02d" % [minutes, seconds];

var dmg_number_scene := preload("res://Scenes/damage_number.tscn");

func spawn_damage_number(amount: int, pos: Vector2, color := Color.WHITE):
	var d = dmg_number_scene.instantiate();
	add_child(d);
	d.setup(amount, color, pos);

func get_spawn_cap():
	# Start with 10 enemies
	var base = 10;
	var growth = pow(run_time, 1.15)
	return base + int(growth);

func _on_enemy_spawner_hit_p():
	lives -= 1;
	$CanvasLayer/HUD/LivesLabel.text = "X " + str(lives);
	if lives <= 0:
		get_tree().paused = true;
		var minutes = int(run_time / 60);
		var seconds = int(run_time) % 60;
		var time_string = "%2d:%2d" % [minutes, seconds];
		$CanvasLayer/GameOver/TimeSurvived.text = "Time:" + time_string;
		$CanvasLayer/GameOver/EnemiesKilled.text = "Enemies killed: " + str(enemies_killed);
		$CanvasLayer/GameOver/CoinsCollected.text = "Coins: " + str(coins);
		$CanvasLayer/GameOver.show();

func update_coins():
	$CanvasLayer/HUD/CoinsLabel.text = "Coins: " + str(coins);

func _on_wave_over_timer_timeout() -> void:
	reset_wave();

func _on_restart_timer_timeout() -> void:
	get_tree().paused = false;

func is_wave_completed():
	#var all_dead = true;
	var enemies = get_tree().get_nodes_in_group("enemies");
	#Check if all enemies have spawned first
	if enemies_spawned >= max_enemies and enemies.size() == 0:
		return true;
	return false;

func spawn_bounce_bullet(from_enemy, ricochet_left: int):
	var enemies = get_tree().get_nodes_in_group("enemies");
	if enemies.size() <= 1:
		return;
	# Find nearest enemy to the one we hit
	var nearest = null;
	var nearest_dist = INF;
	for e in enemies:
		if e == from_enemy:
			continue;
		var dist = e.global_position.distance_to(from_enemy.global_position);
		if dist < nearest_dist:
			nearest_dist = dist;
			nearest = e;
	if nearest == null:
		return;
	# Spawn a new bullet
	var bullet_scene = preload("res://Scenes/bullet.tscn");
	var b = bullet_scene.instantiate();
	b.global_position = from_enemy.global_position;
	b.direction = (nearest.global_position - from_enemy.global_position).normalized();
	b.damage = $Player.stats.damage # or scale it down if necessary
	b.ricochet_left = ricochet_left;
	b.rotation = b.direction.angle();
	call_deferred("add_child", b);

func spawn_explosion1(pos: Vector2):
	var explosion_scene = preload("res://Scenes/explosion1.tscn");
	var explosion = explosion_scene.instantiate();
	explosion.global_position = pos;
	# Must be deferred because bullets spawn explosions inside physics callbacks
	call_deferred("add_child", explosion);
	# Screen shake
	screen_shake(0.20, 10);

func spawn_explosion2(pos: Vector2):
	var explosion_scene = preload("res://explosion2.tscn");
	var explosion = explosion_scene.instantiate();
	explosion.global_position = pos;
	# Must be deferred because bullets spawn explosions inside physics callbacks
	call_deferred("add_child", explosion);
	# Screen shake
	screen_shake(0.20, 10);

func spawn_homing_missile():
	print("MISSILE ATTEMPT");
	var missile_scene = preload("res://Scenes/missile.tscn");
	var missile = missile_scene.instantiate();
	# Spawn behind the player
	missile.global_position = $Player.global_position;
	# Assign target
	missile.target = null;
	missile.split = missile_split;
	missile.cluster = missile_cluster;
	missile.armageddon = missile_armageddon;
	call_deferred("add_child", missile);
	screen_shake(0.25, 12);
	print('MISSILE SPAWNED');

func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemies");
	if enemies.is_empty():
		return null;
	var player_pos = $Player.global_position;
	var nearest = null;
	var nearest_dist = INF;
	for e in enemies:
		var dist = e.global_position.distance_to(player_pos);
		if dist < nearest_dist: # Behind the player
			nearest_dist = dist;
			nearest = e;
	return nearest;

func _upgrade_quick_fire():
	$Player.stats.fire_rate_multiplier *= 0.65;
	var gun = $Player.get_node_or_null("GunPivot");
	if gun:
		gun.apply_stats();

func _upgrade_boost():
	$Player.stats.move_speed += 20;
	$Player.apply_stats();

func _upgrade_extra_life():
	$Player.stats.max_health += 1;
	lives += 1;
	$CanvasLayer/HUD/LivesLabel.text = "X " + str(lives);

func _upgrade_orbit_speed_blade():
	for blade in $Player.get_children():
		if blade.has_method("upgrade_speed"):
			blade.upgrade_speed();

func _upgrade_damage_up():
	$Player.stats.damage += 3;

func _upgrade_orbit_blade():
	has_orbit_blade = true;
	var orbit = preload("res://Scenes/orbital_weapon.tscn").instantiate();
	$Player.add_child(orbit);

func _upgrade_orbit_gun():
	has_orbit_gun = true;
	for gun in $Player.get_children():
		if gun.has_method("apply_stats"):
			gun.apply_stats();
	var gun_scene = preload("res://OrbitGun.tscn");
	var gun = gun_scene.instantiate();
	 # Assign offset based on weapon_count
	if weapon_count < weapon_offsets.size():
		gun.offset = weapon_offsets[weapon_count]
	else:
		# If more weapons than offsets, place randomly around player
		gun.offset = Vector2(randf_range(-20, 20), randf_range(-20, 20));
	gun.stats = preload("res://Data/orbit_gun_stats.tres");
	# Assign sprite index (LIMITED)
	if weapon_count < orbit_gun_sprites.size():
		gun.sprite_index = weapon_count;
	else:
		# Option A: reuse last sprite
		#gun.sprite_index = orbit_gun_sprites.size() - 1;
		# Option B: random sprite
		gun.sprite_index = randi() % orbit_gun_sprites.size();
		# Option C: stop spawning guns
		#return;
	$Player.add_child(gun);
	weapon_count += 1;

func _upgrade_orbit_gun_damage():
	for gun in $Player.get_children():
		if gun is OrbitGun:
			gun.stats.damage += 1;
			gun.apply_stats();

func _upgrade_orbit_gun_fire_rate():
	for gun in $Player.get_children():
		if gun is OrbitGun:
			gun.stats.fire_rate *= 0.85;
			gun.apply_stats();

func _upgrade_aoe_aura():
	# If aura already unlocked but missing, respawn it
	var existing = $Player.get_node_or_null("AOE_AURA");
	if has_aoe_aura and existing == null:
		var aura = preload("res://Scenes/aoe_aura.tscn").instantiate();
		aura.name = "AOE_AURA";
		$Player.add_child(aura);
		return;
	# First time unlock
	if !has_aoe_aura:
		var aura = preload("res://Scenes/aoe_aura.tscn").instantiate();
		aura.name = "AOE_AURA";
		$Player.add_child(aura);
		has_aoe_aura = true;
	# Evolution levels
	aura_level += 1;
	match aura_level:
		1:
			aura_radius = 70;
		2:
			aura_radius = 100;
		3:
			aura_dot = true;
		4:
			aura_pulse = true;
	var aura = $Player.get_node_or_null("AOE_AURA");
	if aura:
		aura.set_radius(aura_radius);

func _upgrade_aoe_aura_damage():
	var aura = $Player.get_node_or_null("AOE_AURA");
	if aura:
		aura.damage += 1;

func _upgrade_aoe_aura_radius():
	var aura = $Player.get_node_or_null("AOE_AURA");
	if aura:
		aura.set_radius(aura.radius + 20);

func trigger_lightning():
	var enemies = get_tree().get_nodes_in_group("enemies");
	if enemies.size() == 0:
		return;
	var player_pos = $Player.global_position
	var nearest = null;
	var nearest_dist = INF;
	for e in enemies:
		var dist = e.global_position.distance_to(player_pos);
		if dist < nearest_dist:
			nearest_dist = dist;
			nearest = e;
	if nearest == null:
		return;
	var bolt = preload("res://Scenes/lightning_strike.tscn").instantiate();
	bolt.has_aoe = lightning_aoe;
	bolt.damage = lightning_damage;
	bolt.chain_count = lightning_chain;
	add_child(bolt);
	screen_shake(0.15, 8);
	bolt.strike(nearest);

func _upgrade_lightning():
	lightning_level += 1;
	has_lightning = true;
	match lightning_level:
		1:
			lightning_cooldown = 2.0;
			lightning_timer = 0.0;
		2:
			lightning_chain += 1;
		3:
			lightning_aoe = true;
		4:
			lightning_cooldown = 1.5;

func _upgrade_lightning_damage():
	lightning_damage += 10;

func _upgrade_lightning_chain():
	lightning_chain += 1;

func _upgrade_pickup_range():
	$Player.stats.pickup_radius += 20;
	$Player.apply_stats();

func _upgrade_acid_pool():
	# First time unlocking
	if acid_dropper == null:
		acid_dropper = load("res://Data/acid_dropper.gd").new()
		return;
	# Leveling up
	acid_dropper.level += 1;
	match  acid_dropper.level:
		2:
			acid_dropper.cooldown = 4.0;
		3:
			acid_dropper.cooldown = 3.0;
		4:
			acid_dropper.cooldown = 2.5;
		5: 
			acid_dropper.cooldown = 2.0;

func _upgrade_acid_radius():
	if acid_dropper == null:
		return;
	acid_dropper.radius_multiplier += 0.55;

func _upgrade_acid_double():
	if acid_dropper == null:
		return;
	acid_dropper.multi_drop += 1;

func _upgrade_bullet_bounce():
	bullet_level += 1;
	has_bullet_bounce = true;
	bullet_ricochet = 1;

func _upgrade_bullet_ricochet_rounds():
	bullet_ricochet += 1;

func _upgrade_explosive_ricochet():
	bullet_level += 1;
	bullet_explosive = true;

func _upgrade_bullet_shrapnel():
	bullet_level += 1;
	bullet_shrapnel = true;

func _upgrade_homing_missile():
	missile_level += 1;
	has_homing_missile = true;
	match missile_level:
		1:
			missile_cooldown = 4.0;
		2:
			missile_split = true;
		3:
			missile_cluster = true;
		4:
			missile_armageddon = true;

func _upgrade_missile_armageddon():
	missile_level += 1;
	missile_armageddon = true;

func _upgrade_missile_split():
	missile_level += 1;
	missile_split = true;

func _upgrade_missile_cluster():
	missile_level += 1;
	missile_cluster = true;

func _upgrade_orbit_gun_pierce():
	for gun in $Player.get_children():
		if gun is OrbitGun:
			gun.stats.pierce += 1;

func _on_option_1_pressed() -> void:
	$UpgradeManager.apply_upgrade(0, self);
	close_level_up_panel();

func _on_option_2_pressed() -> void:
	$UpgradeManager.apply_upgrade(1, self);
	close_level_up_panel();

func _on_option_3_pressed() -> void:
	$UpgradeManager.apply_upgrade(2, self);
	close_level_up_panel();

func _on_reroll_button_pressed() -> void:
	if coins < 1:
		print("Insuffient coins");
		return;
	# Deduct coins
	coins -= reroll_cost
	update_coins();
	# Increase reroll cost (Scaling)
	reroll_cost = int(reroll_cost * 1.25) + 5 # Example scaling curve
	# Get new upgrades choices
	var choices = $UpgradeManager.get_random_upgrades(self);
	#Update UI
	$CanvasLayer/LevelUpPanel/Option1.text = choices[0].name;
	$CanvasLayer/LevelUpPanel/Option2.text = choices[1].name;
	$CanvasLayer/LevelUpPanel/Option3.text = choices[2].name;
	
	$CanvasLayer/LevelUpPanel/Option1/Icon.texture = choices [0].icon;
	$CanvasLayer/LevelUpPanel/Option2/Icon.texture = choices [1].icon;
	$CanvasLayer/LevelUpPanel/Option3/Icon.texture = choices [2].icon;
	
	$CanvasLayer/LevelUpPanel/Option1/DescLabel.text = choices[0].description;
	$CanvasLayer/LevelUpPanel/Option2/DescLabel.text = choices[1].description;
	$CanvasLayer/LevelUpPanel/Option3/DescLabel.text = choices[2].description;
	
	$CanvasLayer/LevelUpPanel/RerollButton.text = "Reroll (-" + str(reroll_cost) + " Coins)";
	$CanvasLayer/LevelUpPanel/RerollButton.disabled = coins < reroll_cost;
