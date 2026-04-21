extends Node

class Upgrade:
	var name: String
	var description: String
	var apply_func: String
	var icon: Texture2D;
	
	func _init(_name, _description, _apply_func, _icon):
		name = _name;
		description = _description;
		apply_func = _apply_func;
		icon = _icon;

var upgrades: Array = [];
var current_choices: Array = [];

var icon_quick_fire = preload("res://Player/gun_box.png");
var icon_coffee = preload("res://Player/coffee_box.png");
var icon_oneup = preload("res://Player/health_box.png");
var icon_damage = preload("res://Player/Iron Sword.png");
var icon_orbit = preload("res://Scenes/Pixel Art Icon Pack - RPG/Weapon & Tool/Silver Sword.png");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upgrades = [
		Upgrade.new("Quick Fire", "Shoot faster", "_upgrade_quick_fire", icon_quick_fire),
		Upgrade.new("Boost", "Move faster for a short time", "_upgrade_boost", icon_coffee),
		Upgrade.new("Extra Life", "Gain +1 life", "_upgrade_extra_life", icon_oneup),
		Upgrade.new("Damage Up", "Increase bullet damage by +2.", "_upgrade_damage_up", icon_damage),
		Upgrade.new("Orbiting Blade", "A blade rotates around you.", "_upgrade_orbit_blade", icon_orbit)
	]

func get_random_upgrades() -> Array:
	var pool = upgrades.duplicate();
	pool.shuffle();
	current_choices = pool.slice(0, 3);
	return current_choices;

func apply_upgrade(index: int, main: Node):
	var upgrade = current_choices[index];
	main.call(upgrade.apply_func);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
