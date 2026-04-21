extends Node2D

@export var orbit_radius := 80
@export var orbit_speed := 2.0   # radians per second
@export var damage := 1

var angle := 0.0;
@onready var Player = get_parent();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	angle += orbit_speed * delta;
	global_position = Player.global_position + Vector2(cos(angle), sin(angle)) * orbit_radius;

func _on_area_2d_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage);
