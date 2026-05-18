extends Area2D

@export var damage := 20;
@export var radius := 45;

# Called when the node enters the scene tree for the first time.
func _ready():
# Set radius
	$CollisionShape2D.shape.radius = radius;
	# Play Animation
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default");
# Wait one frame so the Area2D becomes active
	await get_tree().physics_frame;
# Now the AoE will detect ALL enemies inside
	for body in get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage);
	# Auto-free after animation
	if has_node("AnimatedSprite2D"):
		await $AnimatedSprite2D.animation_finished;
	queue_free();
