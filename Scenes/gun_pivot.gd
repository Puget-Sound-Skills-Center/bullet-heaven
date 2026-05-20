extends Node2D

@export var fire_rate := 0.25;
var can_shoot := true;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position();
	look_at(mouse_pos);
	 # Flip gun sprite vertically if player is flipped
	var player = get_parent();
	var body = player.get_node("AnimatedSprite2D");
	$GunSprite.flip_v = (body.scale.x == -1);

func shoot():
	if !can_shoot:
		return;
	can_shoot = false;
	$ShotTimer.start();
	var bullet_scene = preload("res://Scenes/bullet.tscn");
	var bullet = bullet_scene.instantiate();
	bullet.global_position = $Muzzle.global_position;
	bullet.direction = (get_global_mouse_position() - global_position).normalized();
	bullet.damage = get_parent().stats.damage;
	get_tree().current_scene.add_child(bullet);


func _on_shot_timer_timeout() -> void:
	can_shoot = true;
