extends Control

func _ready() -> void:
	show_scene(GameManager.current_scene_id)

func show_scene(scene_id: String) -> void:
	var story: Dictionary = GameManager.story_data.get("scenes", {})
	var scene = story.get(scene_id)
	if scene == null:
		return
	$Title.text = scene.get("title", "")
	$Text.text = scene.get("text", "")
	for child in $Choices.get_children():
		child.queue_free()
	for choice in scene.get("choices", []):
		var btn := Button.new()
		btn.text = choice.get("text", "Choice")
		btn.pressed.connect(func():
			GameManager.current_level_id = choice.get("nextLevel", "level_1")
			GameManager.current_scene_id = scene_id
			GameManager.save_progress()
			get_tree().change_scene_to_file("res://scenes/LevelScene.tscn")
		)
		$Choices.add_child(btn)
