extends Control

func _ready() -> void:
	GameManager.set_scene_rotation("StoryScene")
	show_scene(GameManager.current_scene_id)

func show_scene(scene_id: String) -> void:
	var story: Dictionary = GameManager.story_data.get("scenes", {})
	var scene = story.get(scene_id)
	if scene == null:
		return
	
	$ContentPanel/TopSection/TitleAndText/Title.text = scene.get("title", "Story")
	$ContentPanel/TopSection/TitleAndText/SceneIndicator.text = "Scene " + scene_id.replace("scene_", "")
	$ContentPanel/MiddleSection/Text.text = scene.get("text", "")
	
	for child in $ContentPanel/ChoiceSection/Choices.get_children():
		child.queue_free()
	
	var choices = scene.get("choices", [])
	if choices.is_empty():
		# Auto proceed to next level if no choices
		await get_tree().create_timer(2.0).timeout
		GameManager.current_level_id = "level_1"
		GameManager.current_scene_id = scene_id
		GameManager.save_progress()
		GameManager.change_scene("res://scenes/LevelScene.tscn", "LevelScene")
		return
	
	for i in range(choices.size()):
		var choice = choices[i]
		var btn := Button.new()
		btn.text = "▶ " + choice.get("text", "Choice")
		btn.custom_minimum_size = Vector2(0, 50)
		
		# Add theme styling for choice buttons
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
		
		btn.add_theme_font_size_override("font_size", 18)
		
		btn.pressed.connect(func():
			GameManager.current_level_id = choice.get("nextLevel", "level_1")
			GameManager.current_scene_id = scene_id
			GameManager.save_progress()
			GameManager.change_scene("res://scenes/LevelScene.tscn", "LevelScene")
		)
		
		$ContentPanel/ChoiceSection/Choices.add_child(btn)
