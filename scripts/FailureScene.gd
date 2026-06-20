extends Control

func _ready() -> void:
	GameManager.set_scene_rotation("FailureScene")

	$ContentPanel/ButtonsSection/RetryButton.pressed.connect(
		_on_retry_pressed
	)

	$ContentPanel/ButtonsSection/AdButton.hide()
	$ContentPanel/ButtonsSection/BoosterButton.hide()

	$ContentPanel/MessageSection/Status.text = "Victor got away. Try again and continue the investigation."

func _on_retry_pressed() -> void:

	GameManager.change_scene(
		"res://scenes/LevelScene.tscn",
		"LevelScene"
	)
