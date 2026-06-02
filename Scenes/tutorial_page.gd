extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Background/AudioStreamPlayer2D.play();
	$Background/BackButton.pressed.connect(_back_button);

func _back_button():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn");
