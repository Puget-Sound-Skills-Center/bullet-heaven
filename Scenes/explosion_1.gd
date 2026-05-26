extends Area2D

@export var damage := 12;
@export var radius := 60;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Play animation
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default");
	# Deal AOE damage
	for body in get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage);
	# Auto-free after animation
	await $AnimatedSprite2D.animation_finished;
	queue_free();
