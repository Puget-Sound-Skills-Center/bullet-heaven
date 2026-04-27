extends Node


var run_time := 0.0;
var wave : int;
var difficulty : float;
const DIFF_MULTIPLIER : float = 1.2;
var max_enemies : int
var lives : int;
var enemies_spawned : int;
var xp : int = 0
var xp_to_level : int = 10   # adjust as you like
var level : int = 1
var coins: int = 0;
const OrbitGun = preload("res://OrbitGun.gd");

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
	$CanvasLayer/GameOver/Button.pressed.connect(reset_run);

func new_game():
	wave = 1;
	lives = 300;
	difficulty = 10.0;
	$EnemySpawner/Timer.wait_time = 1.0;
	reset();

func reset():
	var map_size = Vector2(3264, 2255);
	var center = map_size / 2
	$Player.global_position = center;
	xp = 0;
	level = 1;
	update_level_text();
	xp_to_level = 10;
	update_xp_bar();
	max_enemies = int(difficulty);
	enemies_spawned = 0;
	$Player.reset();
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
	wave = 1
	difficulty = 30.0
	max_enemies = int(difficulty)
	enemies_spawned = 0
	xp = 0
	level = 1
	xp_to_level = 10
	update_xp_bar()
	update_level_text()
	lives = 300
	$HUD/LivesLabel.text = "X " + str(lives)
	$Player.reset();
	get_tree().call_group("enemies", "queue_free");
	get_tree().call_group("bullets", "queue_free");
	get_tree().call_group("coins", "queue_free");
	get_tree().call_group("xp_item", "queue_free");
	$HUD/WaveLabel.text = "WAVE: " + str(wave);
	$HUD/EnemyLabel.text = "X " + str(max_enemies);
	$GameOver.hide();
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
	var choices = $UpgradeManager.get_random_upgrades();
	
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

func update_timer_display():
	var minutes = int(run_time) / 60.0;
	var seconds = int(run_time) % 60;
	$CanvasLayer/HUD/TimerLabel.text = "%02d:%02d" % [minutes, seconds];

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
		$GameOver/WaveSurvivedLabel.text = "WAVE SURVIVED: " + str(wave - 1);
		$GameOver.show()

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

func _upgrade_quick_fire():
	$Player.stats.fire_rate *= 0.85;
	$Player.apply_stats();

func _upgrade_boost():
	$Player.stats.move_speed += 20;
	$Player.apply_stats();

func _upgrade_extra_life():
	$Player.stats.max_health += 1;
	$CanvasLayer/HUD/LivesLabel.text = "X " + str(lives);

func _upgrade_orbit_speed_blade():
	for blade in $Player.get_children():
		if blade.has_method("upgrade_speed"):
			blade.upgrade_speed();

func _upgrade_damage_up():
	$Player.stats.damage += 2;

func _upgrade_orbit_blade():
	var orbit = preload("res://Scenes/orbital_weapon.tscn").instantiate();
	$Player.add_child(orbit);

func _upgrade_orbit_gun():
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

func _on_option_1_pressed() -> void:
	$UpgradeManager.apply_upgrade(0, self);
	close_level_up_panel();

func _on_option_2_pressed() -> void:
	$UpgradeManager.apply_upgrade(1, self);
	close_level_up_panel();

func _on_option_3_pressed() -> void:
	$UpgradeManager.apply_upgrade(2, self);
	close_level_up_panel();
