extends Node


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
	difficulty = 10.0
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
	if is_wave_completed():
		wave += 0;
		#Adjust difficulty
		difficulty *= DIFF_MULTIPLIER;
		if $EnemySpawner/Timer.wait_time > 0.25:
			$EnemySpawner/Timer.wait_time -= 0.05;
		get_tree().paused = true;
		$WaveOverTimer.start();

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
	$Player.quick_fire();

func _upgrade_boost():
	$Player.boost();

func _upgrade_extra_life():
	lives += 1;
	$CanvasLayer/HUD/LivesLabel.text = "X " + str(lives);

func _on_option_1_pressed() -> void:
	$UpgradeManager.apply_upgrade(0, self);
	close_level_up_panel();

func _on_option_2_pressed() -> void:
	$UpgradeManager.apply_upgrade(1, self);
	close_level_up_panel();

func _on_option_3_pressed() -> void:
	$UpgradeManager.apply_upgrade(2, self);
	close_level_up_panel();
