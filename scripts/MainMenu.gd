extends Control

func _ready() -> void:
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/ContinueButton.pressed.connect(_on_continue_pressed)
	$VBoxContainer/ResetButton.pressed.connect(_on_reset_pressed)

func _on_start_pressed() -> void:
	GameManager.reset_progress()
	get_tree().change_scene_to_file("res://scenes/StoryScene.tscn")

func _on_continue_pressed() -> void:
	if GameManager.load_saved_progress():
		get_tree().change_scene_to_file("res://scenes/StoryScene.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/StoryScene.tscn")

func _on_reset_pressed() -> void:
	GameManager.reset_progress()
