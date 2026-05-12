extends Node

@export var cooldown := 5.0;
@export var pool_scene := preload("res://Scenes/AcidPool.tscn");

var timer := 0.0;
var level := 1;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta;
	if timer >= cooldown:
		timer = 0.0;
		drop_pool();

func drop_pool():
	var pool = pool_scene.instantiate();
	pool.global_position = get_parent().global_position;
	get_tree().current_scene.add_child(pool);
