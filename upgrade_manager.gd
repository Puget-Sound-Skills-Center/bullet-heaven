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
var icon_orbit = preload("res://Scenes/SpritesOther/WeaponUnlock.png");
var icon_orbit_gun = preload("res://Weapons/GunPack/Pack 1/1px/24.png");
var icon_orbit_speed = preload("res://Scenes/Pixel Art Icon Pack - RPG/Weapon & Tool/Silver Sword.png")
var icon_pickup = preload("res://Scenes/SpritesOther/Gem2.png");
var icon_aura = preload("res://Scenes/SpritesOther/SigilSpeedUp.png");
var icon_lightning = preload("res://Scenes/Pixel Art Icon Pack - RPG/Potion/Blue Potion 3.png");
var icon_acid = preload("res://Scenes/Pixel Art Icon Pack - RPG/Potion/Green Potion.png");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upgrades = [
		Upgrade.new("Quick Fire", "Increase fire rate by 15%", "_upgrade_quick_fire", icon_quick_fire),
		Upgrade.new("Move Speed", "Increase move speed by +20", "_upgrade_boost", icon_coffee),
		Upgrade.new("Extra Life", "Increase max HP by +1", "_upgrade_extra_life", icon_oneup),
		Upgrade.new("Damage Up", "Increase bullet damage by +2", "_upgrade_damage_up", icon_damage),
		Upgrade.new("Orbiting Blade", "A blade rotates around you.", "_upgrade_orbit_blade", icon_orbit),
		Upgrade.new("Orbit Gun", "A gun auto-aims and fires.", "_upgrade_orbit_gun", icon_orbit_gun),
		Upgrade.new("Orbit Gun Damage", "Increase orbit gun damage by +1", "_upgrade_orbit_gun_damage", icon_orbit_gun),
		Upgrade.new("Orbit Gun Fire Rate", "Increase orbit gun fire rate by 15%", "_upgrade_orbit_gun_fire_rate", icon_orbit_gun),
		Upgrade.new("Blade Speed", "Increase blade rotation speed", "_upgrade_orbit_speed_blade", icon_orbit_speed),
		Upgrade.new("Pickup Range", "Pick up range increased by 20%", "_upgrade_pickup_range", icon_pickup),
		Upgrade.new("Magic Sigil", "Damage zone surrounding player", "_upgrade_aoe_aura", icon_aura),
		Upgrade.new("Magic Sigil Damage", "Increase damage zone by +1", "_upgrade_aoe_aura_damage", icon_aura),
		Upgrade.new("Magic Sigil Radius", "Increase zone radius by 20%", "_upgrade_aoe_aura_radius", icon_aura),
		Upgrade.new("Lightning Strike", "Chance to strike lightning when firing.", "_upgrade_lightning", icon_lightning),
		Upgrade.new("Lightning Damage", "Lightning deals +10 damage.", "_upgrade_lightning_damage", icon_lightning),
		Upgrade.new("Lightning Chance", "Lightning chance +5%.", "_upgrade_lightning_chance", icon_lightning),
		Upgrade.new("Lightning Chain", "Lightning chains to +1 extra enemy.", "_upgrade_lightning_chain", icon_lightning),
		Upgrade.new("Acid Trip", "Spawns puddles of acid under your feet", "_upgrade_acid_pool", icon_acid),
		Upgrade.new("Acid Radius", "Increase acid puddle radius by 25%", "_upgrade_acid_radius", icon_acid),
		Upgrade.new("Acid Double Drop", "Throw two acid bottles at once", "_upgrade_acid_double", icon_acid),
]

func get_random_upgrades(main: Node) -> Array:
	var pool: Array = [];
	for u in upgrades:
		if is_upgrade_allowed(u, main):
			pool.append(u);
	pool.shuffle();
	current_choices = pool.slice(0, 3);
	return current_choices;

func is_upgrade_allowed(upgrade: Upgrade, main: Node) -> bool:
	match upgrade.apply_func:
		"_upgrade_aoe_aura_damage", "_upgrade_aoe_aura_radius":
			return main.has_aoe_aura;
		"_upgrade_orbit_gun_damage", "_upgrade_orbit_gun_fire_rate":
			return main.has_orbit_gun;
		"_upgrade_orbit_speed_blade":
			return main.has_orbit_blade;
		"_upgrade_lightning_damage", "_upgrade_lightning_chance", "_upgrade_lightning_chain":
			return main.has_lightning;
		"_upgrade_orbit_blade":
			# Only allow gun unlock if player doesn't already have one
			return !main.has_orbit_gun;
		"_upgrade_acid_pool":
			if main.acid_dropper == null:
				return true;
			return main.acid_dropper.level < 5;
		"_upgrade_acid_radius", "_upgrade_acid_double":
			return main.acid_dropper != null;
	return true;

func apply_upgrade(index: int, main: Node):
	var upgrade = current_choices[index];
	main.call(upgrade.apply_func);

func reset():
	current_choices.clear();
	# If you track unlocks or rarity pools, reset them here

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
