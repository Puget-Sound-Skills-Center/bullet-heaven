extends Control

@onready var main = get_node("/root/Main");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false;
	$BackgroundPanel/ResumeButton.pressed.connect(_on_resume_button_pressed);
	$BackgroundPanel/RestartButton.pressed.connect(_on_restart_button_pressed);
	$BackgroundPanel/QuitButton.pressed.connect(_on_quit_button_pressed);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func open():
	visible = true;
	get_tree().paused = true;

func close():
	visible = false;
	get_tree().paused = false;

func _on_resume_button_pressed() -> void:
	main.play_sfx("select");
	close();

func _on_restart_button_pressed() -> void:
	main.play_sfx("select");
	get_tree().paused = false;
	get_tree().reload_current_scene();

func _on_quit_button_pressed() -> void:
	main.play_sfx("select");
	get_tree().paused = false;
	get_tree().change_scene_to_file("res://main.tscn");
