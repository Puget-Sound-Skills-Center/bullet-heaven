extends Resource

@export var cooldown := 5.0;
var timer := 0.0;
var level := 1;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func tick(delta, player_pos, main) -> void:
	timer += delta;
	if timer >= cooldown:
		timer = 0.0;
		drop_pool(player_pos, main);

func drop_pool(player_pos, main):
	var pool_scene := preload("res://Scenes/AcidPool.tscn");
	var pool = pool_scene.instantiate();
	# Spawn slightly above the player
	pool.global_position = player_pos + Vector2(0, -50);
	main.add_child(pool);
