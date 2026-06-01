extends Node2D

@onready var shot_timer := $ShotTimer;
@onready var main = get_node("/root/Main");
@onready var muzzle_flash = $Muzzle/MuzzleFlash;
@export var fire_rate := 0.25;
var can_shoot := true;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position();
	look_at(mouse_pos);
	 # Flip gun sprite vertically if player is flipped
	var player = get_parent();
	var body = player.get_node("AnimatedSprite2D");
	var flipped = (body.scale.x == -1);
	scale.y = -1 if flipped else 1;
	position.x = -30 if flipped else 30;

#func gun_flip():
#	if $GunSprite.flip_v == true:
#		position.x = -30
#	position.x = 30

func shoot():
	if !can_shoot:
		return;
	can_shoot = false;
	$ShotTimer.start();
	# Spawn bullets
	var bullet_scene = preload("res://Scenes/bullet.tscn");
	var bullet = bullet_scene.instantiate();
	bullet.global_position = $Muzzle.global_position;
	bullet.direction = (get_global_mouse_position() - global_position).normalized();
	bullet.damage = get_parent().stats.damage;
	get_tree().current_scene.add_child(bullet);
	main.play_sfx("bullet");
	show_muzzle_flash();

func show_muzzle_flash():
	muzzle_flash.visible = true;
	muzzle_flash.modulate.a = 1.0;
	var rate = fire_rate;
	var scale_factor = clamp(0.5 + (rate * 2.0), 0.4, 1.2);
	muzzle_flash.scale = Vector2(scale_factor, scale_factor);
	muzzle_flash.get_tree().create_timer(0.05).timeout.connect(func():
		muzzle_flash.visible = false);

func apply_stats():
	fire_rate = get_parent().stats.fire_rate * get_parent().stats.fire_rate_multiplier;

func apply_fire_rate_upgrade(multiplier: float):
	fire_rate *= multiplier;
	shot_timer.wait_time = fire_rate;

func _on_shot_timer_timeout() -> void:
	can_shoot = true;
