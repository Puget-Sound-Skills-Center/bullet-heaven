extends Area2D

@export var damage := 3;
@export var tick_rate := 0.5;
@export var duration := 4.0;

# Physics for falling
var velocity := Vector2.ZERO;
var Gravity := 900.0;
var bounce_strength := -200.0;
var has_splashed := false;

var tick_timer := 0.0;
var life_timer := 0.0;

# Upgrade shi
var radius_multiplier := 1.0;

func _ready() -> void:
	# Start slightly above the ground
	velocity = Vector2(randf_range(-120, 120), randf_range(-350, -250));

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not has_splashed:
		physics_fall(delta);
	else:
		puddle_behavior(delta);

func physics_fall(delta):
	velocity.y += Gravity * delta;
	position += velocity * delta;
	# Ground detection (Simple)
	if position.y >= get_ground_y():
		position.y = get_ground_y();
		velocity = Vector2.ZERO;
		has_splashed = true;

func get_ground_y():
	# Adjust based on the map
	return get_parent().get_node("Player").global_position.y;

func play_splash_effect():
	if has_node("AudioStreamPlayer"):
		$AudioStreamPlayer.play();
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.scale *= radius_multiplier;
	if has_node("CollisionShape2D"):
		$CollisionShape2D.shape.radius *= radius_multiplier;

func puddle_behavior(_delta):
	tick_timer += _delta;
	life_timer += _delta;
# Deal damage every tick_rate
	if tick_timer >= tick_rate:
		tick_timer = 0.0;
		for body in get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(damage);
	# Remove after duration
	if life_timer >= duration:
		queue_free();
