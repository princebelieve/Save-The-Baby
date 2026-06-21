extends Control

var typing_speed = 0.03
var is_skipping = false

func _ready() -> void:
	randomize()
	GameManager.set_scene_rotation("IntroScene")
	
	# Connect skip button
	$SkipButton.pressed.connect(_on_skip_pressed)
	
	# Start from scene_overview by default
	var scene_id = GameManager.current_scene_id
	if scene_id.is_empty() or scene_id == "scene_1":
		scene_id = "scene_overview"
	
	await show_scene(scene_id)

func show_scene(scene_id: String) -> void:
	var story = GameManager.story_data.get("scenes", {})
	var scene = story.get(scene_id)
	
	if scene == null:
		print("Scene not found: ", scene_id)
		return
	
	is_skipping = false
	var image_name = scene.get("image", "badge.png")
	
	# Show content panel
	$ContentPanel.show()
	$ContentPanel/TopSection/Title.text = scene.get("title", "Story")
	$ContentPanel/BottomSection/SpeakerLabel.text = scene.get("narrator", "") + ":"
	
	# Only show character display for actual character images
	var character_images = ["badge.png", "david.png", "Victor.png", "etan.png", "detective.png", "police.png", "phone.png", "recorder.png", "opened.png"]
	
	if image_name in character_images:
		# Show character image in top section
		$ContentPanel/TopSection/CharacterDisplay.show()
		$ContentPanel/MiddleSection.hide()
		show_character_image(image_name)
	else:
		# Show scene image in letterbox for overview/kidnapping/police-station
		$ContentPanel/TopSection/CharacterDisplay.hide()
		$ContentPanel/MiddleSection.show()
		show_letterbox_image(image_name)
	
	# Show story text with typing animation
	await show_typing_animation(scene.get("text", ""))
	
	# Show choices
	show_choices(scene.get("choices", []))

func show_letterbox_image(image_name: String) -> void:
	var texture_path = "res://assets/" + image_name
	var texture = load(texture_path)
	
	if texture == null:
		print("Failed to load texture: ", texture_path)
		$ContentPanel/MiddleSection/LetterboxContainer/LetterboxImage.texture = null
		return
	
	$ContentPanel/MiddleSection/LetterboxContainer/LetterboxImage.texture = texture

func show_character_image(image_name: String) -> void:
	var texture_path = "res://assets/" + image_name
	var texture = load(texture_path)
	
	if texture == null:
		print("Failed to load texture: ", texture_path)
		return
	
	# Update character display
	$ContentPanel/TopSection/CharacterDisplay/CharacterImage.texture = texture

func show_typing_animation(full_text: String) -> void:
	var text_label = $ContentPanel/BottomSection/StoryText
	text_label.text = ""
	
	for i in range(len(full_text)):
		if is_skipping:
			text_label.text = full_text
			return
		
		text_label.text += full_text[i]
		await get_tree().create_timer(typing_speed).timeout

func show_choices(choices: Array) -> void:
	# Clear existing buttons
	for child in $ContentPanel/ChoiceSection/ChoiceButtons.get_children():
		child.queue_free()
	
	if choices.is_empty():
		return
	
	for choice in choices:
		var btn = Button.new()
		btn.text = "▶ " + choice.get("text", "Choose")
		btn.custom_minimum_size = Vector2(0, 45)
		
		# Style the button
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0.2, 0.4, 0.7, 0.8)
		style_box.set_corner_radius_all(8)
		btn.add_theme_stylebox_override("normal", style_box)
		
		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = Color(0.3, 0.6, 1.0, 1.0)
		hover_style.set_corner_radius_all(8)
		btn.add_theme_stylebox_override("hover", hover_style)
		
		var pressed_style = StyleBoxFlat.new()
		pressed_style.bg_color = Color(0.5, 0.8, 1.0, 1.0)
		pressed_style.set_corner_radius_all(8)
		btn.add_theme_stylebox_override("pressed", pressed_style)
		
		btn.add_theme_font_size_override("font_size", 16)
		
		var next_scene = choice.get("nextScene", "scene_1")
		var next_level = choice.get("nextLevel", "")
		
		btn.pressed.connect(func():
			GameManager.current_scene_id = next_scene
			if not next_level.is_empty():
				GameManager.current_level_id = next_level
				GameManager.save_progress()
				GameManager.change_scene("res://scenes/LevelScene.tscn", "LevelScene")
			else:
				GameManager.save_progress()
				await show_scene(next_scene)
		)
		
		$ContentPanel/ChoiceSection/ChoiceButtons.add_child(btn)

func _on_skip_pressed() -> void:
	is_skipping = true
	# Jump to level if available, otherwise go to menu
	if not GameManager.current_level_id.is_empty():
		GameManager.change_scene("res://scenes/LevelScene.tscn", "LevelScene")
	else:
		GameManager.change_scene("res://scenes/MainMenu.tscn", "MainMenu")
