extends Control

func _ready() -> void:

	$ContentPanel/ButtonsSection/RetryButton.pressed.connect(
		_on_retry_pressed
	)

	$ContentPanel/ButtonsSection/AdButton.hide()
	$ContentPanel/ButtonsSection/BoosterButton.hide()

	$ContentPanel/MessageSection/Status.text = "Victor got away. Try again and continue the investigation."

func _on_retry_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://scenes/LevelScene.tscn"
	)
