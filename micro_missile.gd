extends Area2D

@onready var main = get_node("/root/Main");

const ROTATION_OFFSET := PI/2;
var target = null;
var active := true;
var speed := 400;
var direction := Vector2.ZERO;
var damage := 10;

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

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage);
		main.spawn_explosion2(global_position);
	queue_free();
