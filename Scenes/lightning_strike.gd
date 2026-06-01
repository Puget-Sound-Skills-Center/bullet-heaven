extends Node2D

@export var damage := 20
@export var chain_count := 0
@export var chain_radius := 120
@export var fork_count := 2;
@export var fork_spread := 60.0;
@export var fork_scale := 0.6;
@export var fork_damage_factor := 0.5;
@onready var main = get_node("/root/Main");

var aoe_flash := preload("res://Scenes/lightning_aoe.tscn");
var target = null;
var has_aoe := false;

func strike(t):
	target = t;
	if target == null:
		queue_free();
		return;
	global_position = target.global_position;
	# Play Animation
	$AnimatedSprite2D.play("strike");
	# Apply damage immediately
	if target.has_method("take_damage"):
		target.take_damage(damage);
	# Play Sound
	if has_node("AudioStreamPlayer2D"):
		$AudioStreamPlayer2D.play();
	# Chain lightning AFTER animation finishes
	if has_aoe:
		_do_aoe_damage(global_position, 60);
		var flash = aoe_flash.instantiate();
		flash.global_position = global_position;
		get_tree().root.add_child(flash);
		main.play_sfx("smoke");
	await $AnimatedSprite2D.animation_finished;
	await get_tree().create_timer(0.01).timeout;
	if chain_count > 0:
		chain_to_next();
	queue_free();

func _do_aoe_damage(pos: Vector2, radius: float):
	var enemies = get_tree().get_nodes_in_group("enemies");
	for e in enemies:
		if e.global_position.distance_to(pos) <= radius:
			if e.has_method("take_damage"):
				e.take_damage(damage);

func chain_to_next():
	# If the original target died, stop chaining
	if not is_instance_valid(target):
		return;
	var enemies = get_tree().get_nodes_in_group("enemies");
	var candinates = [];
	for e in enemies:
		if e != target and e.global_position.distance_to(target.global_position) < chain_radius:
			candinates.append(e);
	if candinates.size() == 0:
		return;
	var next_target = candinates.pick_random();
	var next = preload("res://Scenes/lightning_strike.tscn").instantiate();
	next.damage = damage;
	next.chain_count = chain_count - 1;
	next.chain_radius = chain_radius;
	get_tree().current_scene.add_child(next);
	next.strike(next_target);
