extends Area2D

@export var damage := 2;
@export var tick_rate := 0.4; # Damage every 0.4 seconds
@export var radius := 80; # Starting radius

var tick_timer := 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CollisionShape2D.shape.radius = radius;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Sprite2D.scale = Vector2.ONE * (1.0 + sin(Time.get_ticks_msec() * 0.005) * 0.05);
	tick_timer -= delta;
	if tick_timer <= 0:
		tick_timer = tick_rate;
		damage_enemies();

func flash_aura():
	if $Sprite2D:
		$Sprite2D.modulate = Color(1, 1, 1, 0.4);
		await get_tree().create_timer(0.08).timeout;
		$Sprite2D.modulate = Color(1, 1, 1, 1);

func damage_enemies():
	var hit_something := false;
	for body in get_overlapping_bodies():
		# Goblin root
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(damage)
			hit_something = true;
			continue;
		# Goblin Area2D
		var parent := body.get_parent();
		if parent and parent.is_in_group("enemies") and parent.has_method("take_damage"):
			parent.take_damage(damage);
			hit_something = true;
	if hit_something:
		flash_aura();
