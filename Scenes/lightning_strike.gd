extends Node2D

@export var damage := 20
@export var chain_count := 0
@export var chain_radius := 120

var target = null;

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
	await $AnimatedSprite2D.animation_finished;
	if chain_count > 0:
		chain_to_next();
	queue_free();

func chain_to_next():
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
