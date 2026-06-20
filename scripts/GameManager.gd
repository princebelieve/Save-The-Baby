extends Node

var story_data: Dictionary = {}
var level_data: Dictionary = {}
var current_scene_id: String = "scene_1"
var current_level_id: String = "level_1"
var progress_key: String = "save_the_baby_progress"

func _ready() -> void:
	load_data()
	load_progress()

func load_data() -> void:
	story_data = load_json_file("res://data/story.json")
	level_data = load_json_file("res://data/levels.json")

func load_json_file(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func load_progress() -> void:
	if not FileAccess.file_exists("user://save_the_baby_progress.json"):
		return
	var file: FileAccess = FileAccess.open("user://save_the_baby_progress.json", FileAccess.READ)
	if file == null:
		return
	var data: Variant = JSON.parse_string(file.get_as_text())
	if typeof(data) == TYPE_DICTIONARY:
		current_scene_id = data.get("current_scene_id", current_scene_id)
		current_level_id = data.get("current_level_id", current_level_id)

func save_progress() -> void:
	var save_obj: Dictionary = {
		"current_scene_id": current_scene_id,
		"current_level_id": current_level_id,
	}
	var file := FileAccess.open("user://save_the_baby_progress.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_obj, "  "))
		file.close()

func load_saved_progress() -> bool:
	if not FileAccess.file_exists("user://save_the_baby_progress.json"):
		return false
	var file := FileAccess.open("user://save_the_baby_progress.json", FileAccess.READ)
	if not file:
		return false
	var data: Variant = JSON.parse_string(file.get_as_text())
	if typeof(data) == TYPE_DICTIONARY:
		current_scene_id = data.get("current_scene_id", "scene_1")
		current_level_id = data.get("current_level_id", "level_1")
		return true
	return false

func reset_progress() -> void:
	current_scene_id = "scene_1"
	current_level_id = "level_1"
	if FileAccess.file_exists("user://save_the_baby_progress.json"):
		DirAccess.remove_absolute("user://save_the_baby_progress.json")

func go_to_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
