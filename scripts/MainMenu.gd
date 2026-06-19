extends Control

func _ready() -> void:
	print("MAIN MENU LOADED")

	$MainContent/CentralSection/Buttons/StartButton.pressed.connect(_on_start_pressed)
	$MainContent/CentralSection/Buttons/ContinueButton.pressed.connect(_on_continue_pressed)
	$MainContent/CentralSection/Buttons/ResetButton.pressed.connect(_on_reset_pressed)

func _on_start_pressed() -> void:
	print("START STORY CLICKED")

	GameManager.reset_progress()
	GameManager.current_scene_id = "scene_1"

	var err = get_tree().change_scene_to_file("res://scenes/IntroScene.tscn")
	print("CHANGE SCENE RESULT: ", err)

func _on_continue_pressed() -> void:
	if GameManager.load_saved_progress():
		get_tree().change_scene_to_file("res://scenes/StoryScene.tscn")
	else:
		GameManager.reset_progress()
		GameManager.current_scene_id = "scene_1"
		get_tree().change_scene_to_file("res://scenes/StoryScene.tscn")

func _on_reset_pressed() -> void:
	GameManager.reset_progress()
	GameManager.current_scene_id = "scene_1"
	GameManager.save_progress()
