extends CharacterBody2D
@export var stats: PlayerStats;
@onready var main = get_node("/root/Main");

const NORMAL_SHOT : float = 0.5;
const FAST_SHOT : float = 0.1;
const START_SPEED : int = 200;
const BOOST_SPEED : int = 350;
var speed : float;
var screen_size : Vector2;
var can_shoot : bool;
var pickup_radius := 60.0;
#var damage = 1;
var weapon_count := 0;

signal shoot(pos, dir, damage);

func _ready():
	add_to_group("player");
	screen_size = get_viewport_rect().size
	reset();

func reset():
	can_shoot = true;
	position = Vector2(1632, 1128);
	speed = stats.move_speed;
	$ShotTimer.wait_time = stats.fire_rate;

func clear_weapon():
	for child in get_children():
		if child.name.begins_with("apply_stats") or child.has_method("upgrade_speed"):
			child.queue_free();
		if child.name == "AOE_AURA":
			child.queue_free();

func reset_stats():
	stats.damage = 1;
	stats.fire_rate = 1.0;
	stats.move_speed = 200;
	stats.max_health = 5;
	stats.pickup_radius = 60;
	apply_stats();

func get_input():
	#Keyboard Input
	var input_dir = Input.get_vector("Left", "Right", "Up", "Down");
	velocity = input_dir.normalized() * speed
	
	#Aiming with right stick
	var aim = Vector2(Input.get_action_strength("Aim_Right") - Input.get_action_strength("Aim_Left"), Input.get_action_strength("Aim_Down") - Input.get_action_strength("Aim_Up"));
	var using_stick = aim.length() > 0.2

	#Mouse clicks/Contoller
	var shoot_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_action_just_pressed("Shoot");
	if shoot_pressed and can_shoot:
		var dir 
		if using_stick:
			dir = aim.normalized();
		else:
			dir = (get_global_mouse_position() - position).normalized();
		shoot.emit(position, dir, stats.damage);
		if main.has_lightning:
			if randf() < main.lightning_chance:
				main.trigger_lightning();
		if main.has_homing_missile and randf() < main.homing_missile_chance:
			main.spawn_homing_missile();
		can_shoot = false;
		$ShotTimer.start();

func update_rotation():
	# If the player is moving horizontally, flip the sprite
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true;
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false;

func _physics_process(_delta):
	#Player Movement
	get_input();
	move_and_slide();
	
	#limit movement to window size
	#position = position.clamp(Vector2.ZERO, screen_size);
	update_rotation();
	
	#Player Animation
	if velocity.length() != 0:
		$AnimatedSprite2D.play();
	else:
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = 1;

func apply_stats():
	speed = stats.move_speed;
	$ShotTimer.wait_time = stats.fire_rate;
	pickup_radius = stats.pickup_radius;
	$PickupArea/CollisionShape2D.shape.radius = pickup_radius;

func boost():
	$BoostTimer.start()
	speed = BOOST_SPEED;

func update_fire_rate():
	$ShotTimer.wait_time = stats.fire_rate;

func _on_shot_timer_timeout():
	can_shoot = true;

func _on_boost_timer_timeout():
	speed = START_SPEED;

func _on_fast_fire_timer_timeout():
	$ShotTimer.wait_time = NORMAL_SHOT;

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("xp_item"):
		main.add_xp(body.value)
		body.queue_free();
