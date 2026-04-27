extends Node2D

@export var orbit_radius := 80
@export var orbit_speed := 2.0   # radians per second
@export var damage := 1
@export var sprite_forward_offset := -PI/2;

var angle := 0.0;
@onready var Player = get_parent();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	angle += orbit_speed * delta;
	global_position = Player.global_position + Vector2(cos(angle), sin(angle)) * orbit_radius;
	#Visual spin
	var desired = angle + sprite_forward_offset;
	$Sprite2D.rotation = desired;
	if desired > PI/2 or desired < -PI/2:
		$Sprite2D.flip_v = true
	else:
		$Sprite2D.flip_v = false

func upgrade_speed():
	rotation += 2;

func _on_area_2d_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage);
