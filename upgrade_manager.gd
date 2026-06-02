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

var icon_quick_fire = preload("res://Scenes/UI/gun-upgd_15.png");
var icon_coffee = preload("res://Scenes/UI/move_speed+20.png");
var icon_oneup = preload("res://Scenes/UI/extra_life+1HP.png");
var icon_damage = preload("res://Scenes/UI/gun-upgd_15.png");
var icon_damage2 = preload("res://Scenes/UI/Bullet_dmgincrease+2.png");
var icon_orbit = preload("res://Scenes/SpritesOther/WeaponUnlock.png");
var icon_orbit_gun = preload("res://Weapons/GunPack/Pack 1/1px/24.png");
var icon_orbit_speed = preload("res://Scenes/Pixel Art Icon Pack - RPG/Weapon & Tool/Silver Sword.png")
var icon_pickup = preload("res://Scenes/SpritesOther/Gem2.png");
var icon_aura = preload("res://Scenes/SpritesOther/SigilSpeedUp.png");
var icon_lightning = preload("res://Scenes/Pixel Art Icon Pack - RPG/Potion/Blue Potion 3.png");
var icon_acid = preload("res://Scenes/SpritesOther/acidtripBALL.png");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upgrades = [
		Upgrade.new("Quick Fire", "Increase fire rate by 15%", "_upgrade_quick_fire", icon_quick_fire),
		Upgrade.new("Move Speed", "Increase move speed by +20", "_upgrade_boost", icon_coffee),
		Upgrade.new("Extra Life", "Increase max HP by +1", "_upgrade_extra_life", icon_oneup),
		Upgrade.new("Damage Up", "Increase bullet damage by +2", "_upgrade_damage_up", icon_damage2),
		Upgrade.new("Orbiting Blade", "A blade rotates around you.", "_upgrade_orbit_blade", icon_orbit),
		Upgrade.new("Orbit Gun", "A gun auto-aims and fires.", "_upgrade_orbit_gun", icon_orbit_gun),
		Upgrade.new("Orbit Gun Damage", "Increase orbit gun damage by +1", "_upgrade_orbit_gun_damage", icon_orbit_gun),
		Upgrade.new("Orbit Gun Fire Rate", "Increase orbit gun fire rate by 15%", "_upgrade_orbit_gun_fire_rate", icon_orbit_gun),
		Upgrade.new("Blade Speed", "Increase blade rotation speed", "_upgrade_orbit_speed_blade", icon_orbit_speed),
		Upgrade.new("Pickup Range", "Pick up range increased by 20%", "_upgrade_pickup_range", icon_pickup),
		Upgrade.new("Magic Sigil", "Damage zone surrounding player", "_upgrade_aoe_aura", icon_aura),
		Upgrade.new("Magic Sigil Damage", "Increase damage zone by +1", "_upgrade_aoe_aura_damage", icon_aura),
		Upgrade.new("Magic Sigil Radius", "Increase zone radius by 20%", "_upgrade_aoe_aura_radius", icon_aura),
		Upgrade.new("Lightning Strike", "Strkes enemy every 2 seconds.", "_upgrade_lightning", icon_lightning),
		Upgrade.new("Lightning Damage", "Lightning deals +10 damage.", "_upgrade_lightning_damage", icon_lightning),
		Upgrade.new("Lightning Chain", "Lightning chains to +1 extra enemy.", "_upgrade_lightning_chain", icon_lightning),
		Upgrade.new("Acid Trip", "Spawns puddles of acid under your feet", "_upgrade_acid_pool", icon_acid),
		Upgrade.new("Acid Radius", "Increase acid puddle radius by 25%", "_upgrade_acid_radius", icon_acid),
		Upgrade.new("Acid Double Drop", "Throw two acid bottles at once", "_upgrade_acid_double", icon_acid),
		Upgrade.new("Bullet Bounce", "70% chance for bullets to ricochet", "_upgrade_bullet_bounce", icon_damage),
		Upgrade.new("Explosive bullets", "Bullets explode on hit, dealing +20 damage.", "_upgrade_explosive_ricochet", icon_damage),
		Upgrade.new("Homing Missile", "Home in a missile at an enemy every 4 seconds", "_upgrade_homing_missile", icon_damage),
		Upgrade.new("Bullet piercing", "Orbital guns pierces through +1 enemy", "_upgrade_orbit_gun_pierce", icon_orbit_gun),
		Upgrade.new("Split Missile", "Missiles split into 2 mini-rockets.", "_upgrade_missile_split", icon_damage),
		Upgrade.new("Cluster Missile", "Missiles spawn micro-rockets on hit.", "_upgrade_missile_cluster", icon_damage),
		Upgrade.new("Armageddon Missile", "Missiles explode into cluster bombs.", "_upgrade_missile_armageddon", icon_damage),
		Upgrade.new("Forked Lightning", "Lightning jumps to 5 enemies and creates AoE.", "_upgrade_lightning_chain", icon_lightning),
		Upgrade.new("Ricochet Rounds", "Bullets bounce 2 times.", "_upgrade_bullet_ricochet_rounds", icon_damage),
		Upgrade.new("Shrapnel Storm", "Bullets explode into shrapnel.", "_upgrade_bullet_shrapnel", icon_damage),
		Upgrade.new("Burning Sigil", "Aura deals damage over time.", "_upgrade_aoe_aura_damage", icon_aura),
		Upgrade.new("Shockwave Sigil", "Aura pulses every 1.5 seconds.", "_upgrade_aoe_aura_radius", icon_aura),
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
# -------------------------
# AURA
# -------------------------
		"_upgrade_aoe_aura":
			return !main.has_aoe_aura and main.level >= 2
		"_upgrade_aoe_aura_damage":
			return main.has_aoe_aura and main.aura_level >= 1 and main.level >= 6 and !main.aura_dot
		"_upgrade_aoe_aura_radius":
			return main.has_aoe_aura and main.aura_level >= 1 and main.level >= 7 and main.aura_radius < 200
# -------------------------
# ORBIT GUN
# -------------------------
		"_upgrade_orbit_gun":
			return !main.has_orbit_gun and main.level >= 2
		"_upgrade_orbit_gun_damage":
			return main.has_orbit_gun and main.level >= 4
		"_upgrade_orbit_gun_fire_rate":
			return main.has_orbit_gun and main.level >= 4
		"_upgrade_orbit_gun_pierce":
			return main.has_orbit_gun and main.level >= 6
# -------------------------
# ORBIT BLADE
# -------------------------
		"_upgrade_orbit_blade":
			return !main.has_orbit_blade and main.level >= 2
		"_upgrade_orbit_speed_blade":
			return main.has_orbit_blade and main.level >= 4
# -------------------------
# LIGHTNING
# -------------------------
		"_upgrade_lightning":
			return !main.has_lightning and main.level >= 3
		"_upgrade_lightning_damage":
			return main.has_lightning and main.level >= 5
		"_upgrade_lightning_chain":
			return main.has_lightning and main.level >= 7
# -------------------------
# ACID
# -------------------------
		"_upgrade_acid_pool":
			return main.level >= 2 and (main.acid_dropper == null or main.acid_dropper.level < 5)
		"_upgrade_acid_radius":
			return main.acid_dropper != null and main.level >= 4
		"_upgrade_acid_double":
			return main.acid_dropper != null and main.level >= 6
# -------------------------
# BULLET EVOLUTIONS
# -------------------------
		"_upgrade_bullet_bounce":
			return !main.has_bullet_bounce and main.level >= 2
		"_upgrade_bullet_ricochet_rounds":
			return main.has_bullet_bounce and main.level >= 4 and main.bullet_ricochet < 5
		"_upgrade_explosive_ricochet":
			return !main.bullet_explosive and main.level >= 5
		"_upgrade_bullet_shrapnel":
			return main.bullet_explosive and !main.bullet_shrapnel and main.level >= 12
# -------------------------
# MISSILES
# -------------------------
		"_upgrade_homing_missile":
			return !main.has_homing_missile and main.level >= 5
		"_upgrade_missile_split":
			return main.has_homing_missile and !main.missile_split and main.level >= 8
		"_upgrade_missile_cluster":
			return main.has_homing_missile and !main.missile_cluster and main.level >= 12
		"_upgrade_missile_armageddon":
			return main.has_homing_missile and !main.missile_armageddon and main.level >= 16
# -------------------------
# DEFAULT (ALWAYS ALLOWED)
# -------------------------
		"_upgrade_quick_fire":
			return main.level >= 2
		"_upgrade_boost":
			return main.level >= 2
		"_upgrade_extra_life":
			return main.level >= 2
		"_upgrade_damage_up":
			return main.level >= 2
		"_upgrade_pickup_range":
			return main.level >= 2
	return true


func apply_upgrade(index: int, main: Node):
	var upgrade = current_choices[index];
	main.call(upgrade.apply_func);

func reset():
	current_choices.clear();
	# If you track unlocks or rarity pools, reset them here

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
