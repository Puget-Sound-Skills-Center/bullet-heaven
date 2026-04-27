extends Node2D

@export var bullet_scene : PackedScene;
@onready var player = get_parent().get_node("Player")


func _on_player_shoot(pos, dir, dmg):
	var bullet = bullet_scene.instantiate();
	add_child(bullet);
	bullet.position = pos;
	bullet.direction = dir;
	bullet.damage = dmg;
	bullet.add_to_group("bullets");
