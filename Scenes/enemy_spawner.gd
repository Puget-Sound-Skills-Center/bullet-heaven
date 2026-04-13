extends Node2D

@onready var main = get_node("/root/Main");

signal hit_p

var goblin_scene := preload("res://Scenes/goblin.tscn");
var spawn_points := []

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in get_children():
			if i is Marker2D:
				spawn_points.append(i);

func _on_timer_timeout() -> void:
	#Check how many enemies have already been created
	#var enemies = get_tree().get_nodes_in_group("enemies");
	if main.enemies_spawned < main.max_enemies:
		#Pick a random spawn point
		var spawn = spawn_points[randi() % spawn_points.size()];
		#Spawn enemy
		var goblin = goblin_scene.instantiate();
		goblin.position = spawn.position;
		goblin.hit_player.connect(hit);
		main.add_child(goblin);
		goblin.add_to_group("enemies");
		main.enemies_spawned += 1


func hit():
	hit_p.emit();
