extends Node2D

@export var rotation_speed := 1.0;
@export var fire_rate := 1.0;
@export var offset := Vector2.ZERO;
@export var sprite_index := 0;
@export var sprite_forward_offset := -PI/2;

const orbit_gun_sprites = [
	preload("res://Weapons/GunPack/Pack 1/1px/25.png"),
	preload("res://Weapons/GunPack/Pack 1/1px/26.png"),
	preload("res://Weapons/GunPack/Pack 1/1px/28.png"),
	preload("res://Weapons/GunPack/Pack 1/1px/31.png")
] 

var stats: OrbitGunStats;
var angle := 0.0;
@onready var player := get_parent();

func _ready() -> void:
	$Timer.wait_time = stats.fire_rate;
	$Timer.start();
	$Sprite2D.texture = orbit_gun_sprites[sprite_index];

func apply_stats():
	$Timer.wait_time = stats.fire_rate;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == null:
		return;
	# Orbit around player
	global_position = player.global_position + offset;
	# Aim at nearest enemy
	var target = get_nearest_enemy();
	if target:
		var _dir = (target.global_position - global_position).normalized();
		var _desired = _dir.angle() + sprite_forward_offset
		rotation = lerp_angle(rotation, _desired, rotation_speed * delta);
		#Flip logic
		if _desired > PI/2 or _desired < -PI/2:
			$Sprite2D.flip_v = true;
		else:
			$Sprite2D.flip_v = false;

func _on_timer_timeout() -> void:
	var target = get_nearest_enemy();
	if target == null:
		return;
	var dir = (target.global_position - global_position).normalized();
	player.shoot.emit($Muzzle.global_position, dir, stats.damage) #Using the existing bullet logic

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
