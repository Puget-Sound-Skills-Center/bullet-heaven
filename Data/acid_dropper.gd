extends Resource

@export var cooldown := 5.0;
var timer := 0.0;
var level := 1;

var radius_multiplier := 1.0;
var multi_drop := 1;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func tick(delta, player_pos, main) -> void:
	timer += delta;
	if timer >= cooldown:
		timer = 0.0;
		for i in multi_drop:
			drop_pool(player_pos, main);

func drop_pool(player_pos, main):
	var pool_scene := preload("res://Scenes/AcidPool.tscn");
	var pool = pool_scene.instantiate();
	# Spawn slightly above the player
	# Pass radius multiplier to the pool
	pool.radius_multiplier = radius_multiplier;
	pool.global_position = player_pos + Vector2(randf_range(-80, 80), -300);
	main.add_child(pool);
