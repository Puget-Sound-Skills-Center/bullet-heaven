extends Node2D

@export var fire_rate := 0.25;
var can_shoot := true;

func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position();
	var to_mouse = mouse_pos - global_position;
	var angle = to_mouse.angle();
	rotation = angle;
	var player = get_parent();
	# Flip player based on mouse X relative to player
	if mouse_pos.x < player.global_position.x:
		player.scale.x = -1; # Flips player horizontally
	else:
		player.scale.x = 1; # Normal facing

func shoot():
	if !can_shoot:
		return;
	can_shoot = false;
	$ShotTimer.start();
	var dir = (get_global_mouse_position() - global_position).normalized();
	var bullet_scene = preload("res://Scenes/bullet.tscn");
	var b = bullet_scene.instantiate();
	b.global_position = $Muzzle.global_position;
	b.direction = dir;
	b.damage = get_parent().stats.damage
	get_tree().current_scene.add_child(b);

func _on_shot_timer_timeout() -> void:
	can_shoot = true;
