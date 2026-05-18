extends Area2D

@onready var main = get_node("/root/Main");

var speed := 350;
var target = null;
var active := true

const ROTATION_OFFSET := PI/2;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !active:
		return;
	if target == null or !is_instance_valid(target):
		queue_free();
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
			body.take_damage(20);
		main.spawn_explosion2(global_position);
		main.screen_shake(0.3, 8);
		queue_free();
