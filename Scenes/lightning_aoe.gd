extends Node2D

@export var duration := 0.25;
@export var max_scale := 1.8;

var time := 0.0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta;
	var t = time / duration;
	# Scale outward
	scale = Vector2.ONE * lerp(0.2, max_scale, t);
	# Fade out
	modulate.a = 1.0 - t;
	if t >= 1.0:
		queue_free();
