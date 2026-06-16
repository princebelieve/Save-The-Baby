extends Control

func _ready() -> void:
	$VBoxContainer/RetryButton.pressed.connect(_on_retry_pressed)
	$VBoxContainer/AdButton.pressed.connect(_on_ad_pressed)
	$VBoxContainer/BoosterButton.pressed.connect(_on_booster_pressed)
	$Status.text = "Failure is only a delay. You can retry, use a rewarded ad, or take a booster."

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LevelScene.tscn")

func _on_ad_pressed() -> void:
	$Status.text = "Rewarded ad placeholder: +3 extra moves granted for this level."

func _on_booster_pressed() -> void:
	$Status.text = "Booster placeholder: a rescue booster is ready for the next attempt."
