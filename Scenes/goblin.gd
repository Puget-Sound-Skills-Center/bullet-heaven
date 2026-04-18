extends CharacterBody2D

@onready var player = get_node("/root/Main/Player");
@onready var main = get_node("/root/Main");
@export var max_health: int = 3;

var coin_scene := preload("res://Scenes/Coin.tscn");
var explosion_scene := preload("res://Scenes/explosion.tscn");
var xp_scene := preload("res://Scenes/xp_item.tscn");

signal hit_player;

var health: int;
var alive : bool;
var entered : bool;
var speed : int = 100;
var direction : Vector2;
const DROP_CHANCE : float = 0.1;

func _ready():
	var screen_rect = get_viewport_rect();
	health = max_health;
	alive = true;
	entered = false;
	#Pick a direction for the entrance
	var dist = screen_rect.get_center() - position
	#check if need to move horizontally or vertically
	if abs(dist.x) > abs(dist.y):
		#move horizontally
		direction.x = dist.x;
		direction.y = 0;
	else:
		#move vertically
		direction.x = 0;
		direction.y = dist.y

func _physics_process(_delta):
	if alive:
		$AnimatedSprite2D.animation = "Run";
		if entered:
			direction = (player.position - position)
		direction = direction.normalized();
		velocity = direction * speed;
		var enemies = get_tree().get_nodes_in_group("enemies");
		var sep = apply_separation(enemies);
		var _wander = Vector2(randf() - 0.5, randf() - 0.5) * 50
		velocity = (player.global_position - global_position + _wander).normalized() * speed;
		velocity += sep * 1.0  # tweak multiplier
		move_and_slide();
		
		if velocity.x != 0:
			$AnimatedSprite2D.flip_h = velocity.x < 0;
		else:
			pass;


func take_damage(amount: int):
	if not alive:
		return;
	health -= amount;
	flash_hit();
	if health <= 0:
		die();

func flash_hit():
	$AnimatedSprite2D.modulate = Color(18.892, 18.892, 18.892, 1.0)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)

func die():
	alive = false;
	$AnimatedSprite2D.stop();
	$Area2D/CollisionShape2D.set_deferred("disabled", true);
	var xp = xp_scene.instantiate();
	xp.position = position;
	main.call_deferred("add_child", xp);
	if randf() <= DROP_CHANCE:
		drop_coin();
	var explosion = explosion_scene.instantiate();
	explosion.position = position;
	main.add_child(explosion);
	explosion.process_mode = Node.PROCESS_MODE_ALWAYS;
	queue_free();

func drop_coin():
	var coin = coin_scene.instantiate();
	coin.position = position;
	main.call_deferred("add_child", coin);
	coin.add_to_group("items");

func apply_separation(enemies):
	var separation_force = Vector2.ZERO;
	var separation_radius = 40;
	for e in enemies:
		if e == self:
			continue;
		var dist = global_position.distance_to(e.global_position);
		if dist < separation_radius:
			separation_force += (global_position - e.global_position).normalized() * (separation_radius - dist);
	return separation_force;

func _on_entrance_timer_timeout() -> void:
	entered = true;


func _on_area_2d_body_entered(_body: Node2D) -> void:
	hit_player.emit();
