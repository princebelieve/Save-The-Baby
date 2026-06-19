extends Control

var typing_speed = 0.04

func _ready() -> void:
	randomize()
	await show_scene("scene_1")

func show_scene(scene_id: String) -> void:
	var story = GameManager.story_data.get("scenes", {})
	var scene = story.get(scene_id)
	
	if scene == null:
		print("Scene not found: ", scene_id)
		return
	
	# Update title
	$ContentPanel/TopSection/CentralSection/Title.text = scene.get("title", "Story")
	$ContentPanel/TopSection/CentralSection/Subtitle.text = scene.get("narrator", "")
	
	# Handle image display
	var image_path = scene.get("image", "badge.png")
	show_image_section(image_path)
	
	# Show typing animation and await it
	await show_typing_animation(scene.get("text", ""))
	
	# Now show the choices
	show_choices(scene.get("choices", []))

func show_image_section(image_name: String) -> void:
	# Hide all sections first
	$ContentPanel/TopSection/VictorWithEtan.hide()
	$ContentPanel/TopSection/MothersAppeal.hide()
	
	# Show appropriate section based on image
	match image_name:
		"badge.png":
			$ContentPanel/TopSection/MothersAppeal.show()
		_:
			$ContentPanel/TopSection/VictorWithEtan.show()

func show_typing_animation(full_text: String) -> void:
	var text_label = $ContentPanel/MiddleSection/StoryText
	text_label.text = ""
	
	for i in range(len(full_text)):
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
		var next_level = choice.get("nextLevel", "level_1")
		
		btn.pressed.connect(func():
			GameManager.current_level_id = next_level
			GameManager.current_scene_id = next_scene
			GameManager.save_progress()
			get_tree().change_scene_to_file("res://scenes/LevelScene.tscn")
		)
		
		$ContentPanel/ChoiceSection/ChoiceButtons.add_child(btn)
