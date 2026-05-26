extends Area2D

@onready var main = get_node("/root/Main");

var damage := 20;
var speed := 350;
var target = null;
var active := true

const ROTATION_OFFSET := PI/2;

var split := false;
var cluster := false;
var armageddon := false;

var micro_scene := preload("res://micro_missile.tscn");
var cluster_bomb_scene := preload("res://cluster_bomb.tscn");


func _ready() -> void:
	target = main.get_nearest_enemy();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !active:
		return;
	if target == null or !is_instance_valid(target):
		target = main.get_nearest_enemy();
		if target == null:
			return;
	var dir = (target.global_position - global_position).normalized();
	global_position += dir * speed * delta; 
	rotation = dir.angle() + ROTATION_OFFSET;

func _on_body_entered(body) -> void:
	if !active:
		return;
	if body == target:
		active = false;
		if body.has_method("take_damage"):
			body.take_damage(damage);
		# Base explosion
		main.spawn_explosion2(global_position);
		main.screen_shake(0.3, 8);
		# Split evolution
		if main.missile_split:
			_spawn_split_missile();
		# Cluster evolution
		if main.missile_cluster:
			_spawn_cluster_micro_missile();
		# Armageddon evolution
		if main.missile_armageddon:
			_spawn_cluster_bombs();
		queue_free();

func _spawn_split_missile():
	if target == null or !is_instance_valid(target):
		return;
	for i in range(1):
		var m = micro_scene.instantiate();
		m.global_position = global_position;
		var dir = (target.global_position - global_position).normalized();
		# Slight spread
		var angle_offset = deg_to_rad(randf_range(-15, 15))
		m.direction = dir.rotated(angle_offset);
		main.call_deferred("add_child", m);

func _spawn_cluster_micro_missile():
	for i in range(2):
		var m = micro_scene.instantiate();
		m.global_position = global_position;
		var dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized();
		m.direction = dir;
		main.call_deferred("add_child", m);

func _spawn_cluster_bombs():
	for i in range(2):
		var b = cluster_bomb_scene.instantiate();
		b.global_position = global_position;
		main.call_deferred("add_child", b);
