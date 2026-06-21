extends Control

func _ready() -> void:
	print("MAIN MENU LOADED")

	# Load Ethan's image
	var ethan_texture = load("res://assets/etan.png")
	if ethan_texture:
		$MainLayout/EthanContainer/EthanImage.texture = ethan_texture

	# Connect button signals
	$MainLayout/ButtonsContainer/StartButton.pressed.connect(_on_start_pressed)
	$MainLayout/ButtonsContainer/ContinueButton.pressed.connect(_on_continue_pressed)
	$MainLayout/ButtonsContainer/ResetButton.pressed.connect(_on_reset_pressed)

func _on_start_pressed() -> void:
	print("START STORY CLICKED")

	GameManager.reset_progress()
	GameManager.current_scene_id = "scene_overview"

	GameManager.change_scene("res://scenes/IntroScene.tscn", "IntroScene")

func _on_continue_pressed() -> void:
	if GameManager.load_saved_progress():
		GameManager.change_scene("res://scenes/StoryScene.tscn", "StoryScene")
	else:
		GameManager.reset_progress()
		GameManager.current_scene_id = "scene_1"
		GameManager.change_scene("res://scenes/StoryScene.tscn", "StoryScene")

func _on_reset_pressed() -> void:
	GameManager.reset_progress()
	GameManager.current_scene_id = "scene_1"
	GameManager.save_progress()
