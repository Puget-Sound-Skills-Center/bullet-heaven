extends Node2D

var velocity := Vector2(0, -40);   # upward pop
var lifetime := 0.6;               # how long it lasts
var fade_speed := 2.0;             # how fast it fades
var gravity := 20;                 # optional floaty effect
var world_position := Vector2.ZERO;

@onready var label = $Label;

func setup(value: int, color := Color.WHITE, pos := Vector2.ZERO):
	world_position = pos;
	label.text = str(value);
	label.modulate = color;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = world_position;
	world_position += velocity * delta;
	velocity.y += gravity * delta;
	# Fade out
	modulate.a -= fade_speed * delta;
	if modulate.a <= 0:
		queue_free();
	scale = scale.lerp(Vector2(1,1), delta * 10);
