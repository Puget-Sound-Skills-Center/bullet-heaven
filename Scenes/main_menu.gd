extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Musicbackground.play();
	$BoxContainer/Buttons/tutorial_button.pressed.connect(_tutorial_open);
	$BoxContainer/Buttons/start_button.pressed.connect(_start_game);
	$BoxContainer/Buttons/quit_button.pressed.connect(_quit_game);

func _start_game():
	$AudioStreamPlayer2D.play();
	get_tree().change_scene_to_file("res://main.tscn");

func _quit_game():
	$AudioStreamPlayer2D.play();
	get_tree().quit();

func _tutorial_open():
	get_tree().change_scene_to_file("res://Scenes/tutorial_page.tscn");
