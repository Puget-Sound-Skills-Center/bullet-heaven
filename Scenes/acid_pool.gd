extends Area2D

@export var damage := 3;
@export var tick_rate := 0.5;
@export var duration := 4.0;

var tick_timer := 0.0;
var life_timer := 0.0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	tick_timer += delta;
	life_timer += delta;
	# Deal damage every tick_rate
	if tick_timer >= tick_rate:
		for body in get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(damage);
	# Remove after duration
	if life_timer >= duration:
		queue_free();
