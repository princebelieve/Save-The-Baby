extends Control

const BOARD_SIZE := 8

const TILE_DATA := {
	"key": {
		"asset": "res://assets/key.png",
		"name": "Key",
	},
	"clock": {
		"asset": "res://assets/clock.png",
		"name": "Clock",
	},
	"phone": {
		"asset": "res://assets/phone.png",
		"name": "Phone",
	},
	"tape": {
		"asset": "res://assets/tape.png",
		"name": "Tape",
	},
	"fingerprint": {
		"asset": "res://assets/finger-print.png",
		"name": "Fingerprint",
	},
	"chain": {
		"asset": "res://assets/chain.png",
		"name": "Chain",
	},
	"badge": {
		"asset": "res://assets/badge.png",
		"name": "Badge",
	},
	"police": {
		"asset": "res://assets/police.png",
		"name": "Police",
	},
}

var level: Dictionary = { }
var board: Array = []

var selected := Vector2i(-1, -1)

var moves_left := 0
var score := 0

# Swipe detection
var swipe_start_pos := Vector2.ZERO
var swipe_active := false
var swipe_start_tile := Vector2i(-1, -1)


func _ready() -> void:
	randomize()
	GameManager.set_scene_rotation("LevelScene")

	level = GameManager.level_data.get("levels", { }).get(
		GameManager.current_level_id,
		{ },
	)

	moves_left = int(level.get("moves", 25))

	$GamePanel/Title.text = str(
		level.get("levelId", "SAVE ETHAN"),
	)

	$GamePanel/Objective.text = (
			"Find clues and rescue Ethan from Victor"
	)

	$GamePanel/Hint.text = (
			"Swipe with finger to match 3 or more!"
	)

	$GamePanel/Status.text = "Help David find Ethan..."

	_update_labels()

	build_board()


func build_board() -> void:
	board.clear()

	for y in range(BOARD_SIZE):
		var row := []

		for x in range(BOARD_SIZE):
			row.append(_random_tile())

		board.append(row)

	while _has_any_match():
		for y in range(BOARD_SIZE):
			for x in range(BOARD_SIZE):
				board[y][x] = _random_tile()

	_render_board()


func _input(event: InputEvent) -> void:
	# Handle swipe input on the game board
	var grid_node = $GamePanel/BoardContainer/AspectRatioContainer/InnerPanel/GridContainer
	
	if event is InputEventMouseButton:
		if event.pressed:
			# Start swipe
			swipe_start_pos = event.position
			swipe_active = true
			swipe_start_tile = _get_tile_from_position(event.position)
		else:
			# End swipe
			if swipe_active:
				var end_tile = _get_tile_from_position(event.position)
				if swipe_start_tile != Vector2i(-1, -1) and end_tile != Vector2i(-1, -1):
					if _are_adjacent(swipe_start_tile, end_tile):
						_on_swipe(swipe_start_tile, end_tile)
						get_tree().root.set_input_as_handled()
			swipe_active = false


func _get_tile_from_position(pos: Vector2) -> Vector2i:
	var grid_node = $GamePanel/BoardContainer/AspectRatioContainer/InnerPanel/GridContainer
	var grid_rect = grid_node.get_global_rect()
	
	# Check if position is within grid
	if not grid_rect.has_point(pos):
		return Vector2i(-1, -1)
	
	# Calculate tile position
	var local_pos = pos - grid_rect.position
	var tile_size = grid_rect.size / BOARD_SIZE
	
	var tile_x = int(local_pos.x / tile_size.x)
	var tile_y = int(local_pos.y / tile_size.y)
	
	# Clamp to board bounds
	tile_x = clampi(tile_x, 0, BOARD_SIZE - 1)
	tile_y = clampi(tile_y, 0, BOARD_SIZE - 1)
	
	return Vector2i(tile_x, tile_y)


func _on_swipe(from: Vector2i, to: Vector2i) -> void:
	selected = Vector2i(-1, -1)
	
	_swap(from, to)
	
	var matched := await _resolve_matches()
	
	if not matched:
		_swap(to, from)
		$GamePanel/Status.text = "That won't help rescue Ethan."
	else:
		$GamePanel/Status.text = "Great! Found a clue!"
	
	moves_left -= 1
	_update_labels()
	
	if moves_left <= 0:
		_lose()
		return


func _render_board() -> void:
	var grid = $GamePanel/BoardContainer/AspectRatioContainer/InnerPanel/GridContainer
	
	# Clear all children immediately (not queue_free) to avoid index mismatches
	for child in grid.get_children():
		child.free()
	
	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):
			var tile_type = board[y][x]

			# Create a container for the tile
			var tile_container = Control.new()
			tile_container.custom_minimum_size = Vector2(45, 45)
			tile_container.name = "Tile_%s_%s" % [x, y]

			# Create background
			var background = Panel.new()
			background.anchors_preset = 15
			background.anchor_left = 0.0
			background.anchor_top = 0.0
			background.anchor_right = 1.0
			background.anchor_bottom = 1.0

			var tile_colors = {
				"key": Color(0.8, 0.6, 0.2, 1),
				"clock": Color(0.2, 0.8, 0.6, 1),
				"phone": Color(0.2, 0.6, 0.8, 1),
				"tape": Color(0.6, 0.2, 0.8, 1),
				"fingerprint": Color(0.8, 0.8, 0.2, 1),
				"chain": Color(0.8, 0.2, 0.6, 1),
				"badge": Color(0.8, 0.5, 0.2, 1),
				"police": Color(0.3, 0.5, 1.0, 1),
			}
			var color = tile_colors.get(tile_type, Color(0.5, 0.5, 0.5, 1))

			var style_box = StyleBoxFlat.new()
			style_box.bg_color = color
			style_box.set_corner_radius_all(4)
			background.add_theme_stylebox_override("panel", style_box)

			tile_container.add_child(background)

			var texture_rect = TextureRect.new()
			texture_rect.anchors_preset = 15
			texture_rect.anchor_left = 0.0
			texture_rect.anchor_top = 0.0
			texture_rect.anchor_right = 1.0
			texture_rect.anchor_bottom = 1.0

			var texture = load(TILE_DATA[tile_type]["asset"])

			if texture:
				texture_rect.texture = texture
				texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

			tile_container.add_child(texture_rect)


			var button = Button.new()
			button.anchors_preset = 15
			button.anchor_left = 0.0
			button.anchor_top = 0.0
			button.anchor_right = 1.0
			button.anchor_bottom = 1.0
			button.text = ""

			var btn_style = StyleBoxFlat.new()
			btn_style.bg_color = Color(0, 0, 0, 0)

			button.add_theme_stylebox_override("normal", btn_style)
			button.add_theme_stylebox_override("hover", btn_style)
			button.add_theme_stylebox_override("pressed", btn_style)

			button.pressed.connect(func(): _on_tile_pressed(x, y))

			tile_container.add_child(button)

			$GamePanel/BoardContainer/AspectRatioContainer/InnerPanel/GridContainer.add_child(tile_container)

func _on_tile_pressed(x: int, y: int):
	# Swipe system is now primary input method
	# This function is kept for compatibility but not used
	pass


func highlight_selected():
	_render_board()

	if selected.x < 0:
		return

	var tile_name = "Tile_%s_%s" % [selected.x, selected.y]
	var grid = $GamePanel/BoardContainer/AspectRatioContainer/InnerPanel/GridContainer
	var tile_container: Control = grid.get_node_or_null(tile_name)
	
	if not tile_container:
		return

	var tween := create_tween()

	tween.tween_property(
		tile_container,
		"scale",
		Vector2(1.15, 1.15),
		0.15,
	)

	tween.tween_property(
		tile_container,
		"scale",
		Vector2.ONE,
		0.15,
	)


func _are_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return abs(a.x - b.x) + abs(a.y - b.y) == 1


func _swap(a: Vector2i, b: Vector2i):
	var temp = board[a.y][a.x]

	board[a.y][a.x] = board[b.y][b.x]

	board[b.y][b.x] = temp

	_render_board()


func _resolve_matches() -> bool:
	var matches = _find_matches()

	print("MATCHES FOUND: ", matches)

	if matches.is_empty():
		return false

	for group in matches:
		for pos in group:
			await _destroy_tile(pos)

			board[pos.y][pos.x] = ""

		score += group.size() * 10

	_update_labels()

	_fall_tiles()

	_refill_board()

	if not _has_possible_move():
		build_board()
		return true

	_render_board()

	if score >= int(level.get("target", 10)) * 10:
		_win()

	return true


func _destroy_tile(pos: Vector2i):
	var tile_name = "Tile_%s_%s" % [pos.x, pos.y]
	var grid = $GamePanel/BoardContainer/AspectRatioContainer/InnerPanel/GridContainer
	var tile_container = grid.get_node_or_null(tile_name)
	
	if not tile_container:
		return

	var tween = create_tween()

	tween.tween_property(
		tile_container,
		"scale",
		Vector2.ZERO,
		0.2,
	)

	await tween.finished


func _find_matches() -> Array:
	var matches = []

	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):
			if board[y][x] == "":
				continue

			var horiz = [Vector2i(x, y)]

			while x + horiz.size() < BOARD_SIZE and board[y][x + horiz.size()] == board[y][x]:
				horiz.append(
					Vector2i(x + horiz.size(), y),
				)

			if horiz.size() >= 3:
				matches.append(horiz)

			var vert = [Vector2i(x, y)]

			var n = 1

			while y + n < BOARD_SIZE and board[y + n][x] == board[y][x]:
				vert.append(Vector2i(x, y + n))
				n += 1

			if vert.size() >= 3:
				matches.append(vert)

	return matches


func _has_any_match() -> bool:
	return not _find_matches().is_empty()


func _fall_tiles():
	for x in range(BOARD_SIZE):
		for y in range(BOARD_SIZE - 1, -1, -1):
			if board[y][x] == "":
				for above in range(y - 1, -1, -1):
					if board[above][x] != "":
						board[y][x] = board[above][x]
						board[above][x] = ""

						break


func _refill_board():
	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):
			if board[y][x] == "":
				board[y][x] = _random_tile()


func _random_tile() -> String:
	return TILE_DATA.keys().pick_random()


func _update_labels():
	if has_node("GamePanel/MovesLabel"):
		$GamePanel/MovesLabel.text = "Moves: " + str(moves_left)

	if has_node("GamePanel/ScoreLabel"):
		$GamePanel/ScoreLabel.text = "Score: " + str(score)

	if has_node("GamePanel/BabyProgress"):
		var target_score = int(level.get("target", 10)) * 10

		$GamePanel/BabyProgress.value = (
				float(score) / float(target_score)
		) * 100.0


func _win():
	$GamePanel/Status.text = "Excellent! We're getting closer to Ethan!"

	await get_tree().create_timer(1.5).timeout

	GameManager.current_scene_id = "scene_2"

	GameManager.save_progress()

	GameManager.change_scene(
		"res://scenes/StoryScene.tscn",
		"StoryScene"
	)


func _has_possible_move() -> bool:
	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):
			var current = Vector2i(x, y)

			for direction in [
				Vector2i(1, 0),
				Vector2i(0, 1),
			]:
				var target = current + direction

				if target.x >= BOARD_SIZE or target.y >= BOARD_SIZE:
					continue

				_swap_data(current, target)

				var possible = _has_any_match()

				_swap_data(current, target)

				if possible:
					return true

	return false


func _swap_data(a: Vector2i, b: Vector2i):
	var temp = board[a.y][a.x]

	board[a.y][a.x] = board[b.y][b.x]

	board[b.y][b.x] = temp


func _lose():
	$GamePanel/Status.text = "Ethan's trail has gone cold..."

	await get_tree().create_timer(1.0).timeout

	GameManager.change_scene(
		"res://scenes/FailureScene.tscn",
		"FailureScene"
	)
