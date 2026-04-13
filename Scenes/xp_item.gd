extends Area2D

@onready var main = get_node("/root/Main");
@export var xp_amount : int = 1;

func _ready() -> void:
	add_to_group("xp_item");

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		main.add_xp(xp_amount);
		queue_free();
