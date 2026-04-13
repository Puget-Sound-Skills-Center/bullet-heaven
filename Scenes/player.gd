extends CharacterBody2D

const NORMAL_SHOT : float = 0.5;
const FAST_SHOT : float = 0.1;
const START_SPEED : int = 200;
const BOOST_SPEED : int = 300;
var speed : int;
var screen_size : Vector2;
var can_shoot : bool;

signal shoot;

func _ready():
	screen_size = get_viewport_rect().size
	reset();

func reset():
	can_shoot = true;
	position = screen_size/2;
	speed = START_SPEED;
	$ShotTimer.wait_time = NORMAL_SHOT;

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
		shoot.emit(position, dir);
		can_shoot = false;
		$ShotTimer.start();

func update_rotation():
	var aim = Vector2(Input.get_action_strength("Aim_Right") - Input.get_action_strength("Aim_Left"), Input.get_action_strength("Aim_Down") - Input.get_action_strength("Aim_Up"))
	var using_stick = aim.length() > 0.2;
	var angle_dir = Vector2.ZERO;
	if using_stick:
		angle_dir = aim;
	else:
		angle_dir = get_local_mouse_position();
	var angle = snappedf(angle_dir.angle(), PI / 4) / (PI / 4)
	angle = wrapi(int(angle), 0, 8);
	$AnimatedSprite2D.animation = "Walk" + str(angle);

func _physics_process(_delta):
	#Player Movement
	get_input();
	move_and_slide();
	
	#limit movement to window size
	position = position.clamp(Vector2.ZERO, screen_size);
	update_rotation();
	
	#Player Animation
	if velocity.length() != 0:
		$AnimatedSprite2D.play();
	else:
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = 1;

func boost():
	$BoostTimer.start()
	speed = BOOST_SPEED;

func quick_fire():
	$FastFireTimer.start();
	$ShotTimer.wait_time = FAST_SHOT;

func _on_shot_timer_timeout():
	can_shoot = true;


func _on_boost_timer_timeout():
	speed = START_SPEED;


func _on_fast_fire_timer_timeout():
	$ShotTimer.wait_time = NORMAL_SHOT;
