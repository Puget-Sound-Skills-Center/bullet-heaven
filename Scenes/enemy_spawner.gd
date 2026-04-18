extends Node2D

signal hit_p;

@onready var main = get_node("/root/Main");
@onready var Player = main.get_node("Player");
var goblin_scene := preload("res://Scenes/goblin.tscn")

# How far from the player enemies should spawn
var spawn_distance := 650

# How many enemies per tick
var enemies_per_tick := 3

func _on_timer_timeout():
	if main.enemies_spawned >= main.max_enemies:
		return
	var player_pos = Player.global_position;
	for i in enemies_per_tick:
		if main.enemies_spawned >= main.max_enemies:
			break
		var angle = randf() * TAU
		var offset = Vector2(cos(angle), sin(angle)) * spawn_distance
		var spawn_pos = player_pos + offset
		var goblin = goblin_scene.instantiate()
		goblin.global_position = spawn_pos
		goblin.hit_player.connect(hit)
		main.add_child(goblin)
		goblin.add_to_group("enemies")
		main.enemies_spawned += 1

func hit():
	hit_p.emit()
