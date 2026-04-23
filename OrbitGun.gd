extends Node2D

@export var orbit_radius := 80.0;
@export var orbit_speed := 1.0;
@export var fire_rate := 1.0;

var angle := 0.0;
@onready var player := get_parent();

func _ready() -> void:
	$Timer.wait_time = fire_rate;
	$Timer.start();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == null:
		return;
	# Orbit around player
	angle += orbit_speed * delta;
	global_position = player.global_position + Vector2(cos(angle), sin(angle)) * orbit_radius;
	# Aim at nearest enemy
	var target = get_nearest_enemy();
	if target:
		var dir = (target.global_position - global_position).normalized();
		rotation = dir.angle(); # rotate sprite to face target

func _on_timer_timeout() -> void:
	var target = get_nearest_enemy();
	if target == null:
		return;
	var dir = (target.global_position - global_position).normalized();
	player.shoot.emit(global_position, dir) #Using the existing bullet logic

func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemies");
	var closest = null;
	var _closest_dist := INF;
	for e in enemies:
		var d = global_position.distance_to(e.global_position)
		if d < _closest_dist:
			_closest_dist = d;
			closest = e;
	return closest;
