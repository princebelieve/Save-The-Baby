extends Control


const BOARD_SIZE := 6

const TILE_DATA := {
	"bottle": {
		"emoji": "🍼",
		"asset": "res://assets/tiles/bottle.png"
	},
	"bear": {
		"emoji": "🧸",
		"asset": "res://assets/tiles/bear.png"
	},
	"star": {
		"emoji": "⭐",
		"asset": "res://assets/tiles/star.png"
	},
	"key": {
		"emoji": "🔑",
		"asset": "res://assets/tiles/key.png"
	},
	"heart": {
		"emoji": "❤️",
		"asset": "res://assets/tiles/heart.png"
	}
}


var level: Dictionary = {}
var board: Array = []

var selected := Vector2i(-1, -1)

var moves_left := 0
var score := 0


func _ready() -> void:

	randomize()

	level = GameManager.level_data.get("levels", {}).get(
		GameManager.current_level_id,
		{}
	)

	moves_left = int(level.get("moves", 25))


	$GamePanel/Title.text = str(
		level.get("levelId", "SAVE ETHAN")
	)

	$GamePanel/Objective.text = (
		"Mission: " +
		str(level.get("objective","save_baby")).replace("_"," ")
	)

	$GamePanel/Hint.text = (
		"Match 3 items to collect clues and rescue Ethan."
	)


	$GamePanel/Status.text = "Find the first clue."


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



func _render_board() -> void:


	for child in $GamePanel/BoardContainer/GridContainer.get_children():
		child.queue_free()



	for y in range(BOARD_SIZE):

		for x in range(BOARD_SIZE):

			var tile := Button.new()

			tile.custom_minimum_size = Vector2(70,70)

			tile.name = "Tile_%s_%s" % [x,y]


			_apply_tile_visual(
				tile,
				board[y][x]
			)


			tile.pressed.connect(
				func():
					_on_tile_pressed(x,y)
			)


			$GamePanel/BoardContainer/GridContainer.add_child(tile)



func _apply_tile_visual(button:Button, tile:String):

	var data = TILE_DATA[tile]

	var path = data.asset


	if ResourceLoader.exists(path):

		var texture := TextureRect.new()

		texture.texture = load(path)

		texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

		texture.custom_minimum_size = Vector2(55,55)


		button.text = ""

		button.add_child(texture)

	else:

		button.text = data.emoji
		button.add_theme_font_size_override(
			"font_size",
			35
		)



func _on_tile_pressed(x:int,y:int):

	var clicked := Vector2i(x,y)


	if selected.x < 0:

		selected = clicked
		highlight_selected()

		$GamePanel/Status.text = "Choose a tile to swap."

		return



	if selected == clicked:

		selected = Vector2i(-1,-1)
		_render_board()

		return



	if _are_adjacent(selected, clicked):

		var old := selected


		_swap(old, clicked)


		selected = Vector2i(-1,-1)


		var matched := await _resolve_matches()


		if not matched:

			_swap(clicked, old)

			$GamePanel/Status.text = "That move cannot help Ethan."


		else:

			$GamePanel/Status.text = "Great! You found a clue."


		moves_left -= 1

		_update_labels()

		if moves_left <= 0:
			_lose()
			return



	else:

		selected = clicked

		highlight_selected()



func highlight_selected():

	_render_board()


	if selected.x < 0:
		return


	var index := selected.y * BOARD_SIZE + selected.x

	var btn: Button = $GamePanel/BoardContainer/GridContainer.get_child(index)


	btn.modulate = Color(1, 1, 0.4)


	var tween := create_tween()

	tween.tween_property(
		btn,
		"scale",
		Vector2(1.15,1.15),
		0.15
	)

	tween.tween_property(
		btn,
		"scale",
		Vector2.ONE,
		0.15
	)



func _are_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return abs(a.x - b.x) + abs(a.y - b.y) == 1



func _swap(a:Vector2i,b:Vector2i):

	var temp = board[a.y][a.x]

	board[a.y][a.x] = board[b.y][b.x]

	board[b.y][b.x] = temp


	_render_board()



func _resolve_matches() -> bool:


	var matches = _find_matches()


	if matches.is_empty():
		return false



	for group in matches:

		for pos in group:

			await _destroy_tile(pos)


			board[pos.y][pos.x]=""



		score += group.size()*10



	_update_labels()



	_fall_tiles()

	_refill_board()


	if not _has_possible_move():
		build_board()
		return true


	_render_board()



	if score >= int(level.get("target",10))*10:

		_win()


	return true




func _destroy_tile(pos:Vector2i):

	var index = pos.y*BOARD_SIZE+pos.x

	var btn = $GamePanel/BoardContainer/GridContainer.get_child(index)


	var tween=create_tween()


	tween.tween_property(
		btn,
		"scale",
		Vector2.ZERO,
		0.2
	)


	await tween.finished




func _find_matches()->Array:

	var matches=[]


	for y in range(BOARD_SIZE):

		for x in range(BOARD_SIZE):

			if board[y][x]=="":
				continue


			var horiz=[Vector2i(x,y)]


			while x+horiz.size()<BOARD_SIZE and board[y][x+horiz.size()]==board[y][x]:

				horiz.append(
					Vector2i(x+horiz.size(),y)
				)


			if horiz.size()>=3:
				matches.append(horiz)



			var vert=[Vector2i(x,y)]


			var n=1

			while y+n<BOARD_SIZE and board[y+n][x]==board[y][x]:

				vert.append(Vector2i(x,y+n))
				n+=1



			if vert.size()>=3:
				matches.append(vert)



	return matches



func _has_any_match()->bool:

	return not _find_matches().is_empty()



func _fall_tiles():

	for x in range(BOARD_SIZE):

		for y in range(BOARD_SIZE-1,-1,-1):

			if board[y][x]=="":

				for above in range(y-1,-1,-1):

					if board[above][x]!="":

						board[y][x]=board[above][x]
						board[above][x]=""

						break



func _refill_board():

	for y in range(BOARD_SIZE):

		for x in range(BOARD_SIZE):

			if board[y][x]=="":
				board[y][x]=_random_tile()



func _random_tile()->String:

	return TILE_DATA.keys().pick_random()



func _update_labels():

	if has_node("GamePanel/MovesLabel"):
		$GamePanel/MovesLabel.text = "Moves: " + str(moves_left)

	if has_node("GamePanel/ScoreLabel"):
		$GamePanel/ScoreLabel.text = "Score: " + str(score)


	if has_node("GamePanel/BabyProgress"):
		$GamePanel/BabyProgress.value = score



func _win():

	$GamePanel/Status.text="Ethan is closer to being found!"


	await get_tree().create_timer(1.5).timeout


	GameManager.current_scene_id="scene_2"

	GameManager.save_progress()


	get_tree().change_scene_to_file(
		"res://scenes/StoryScene.tscn"
	)


func _has_possible_move() -> bool:

	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):

			var current = Vector2i(x,y)


			for direction in [
				Vector2i(1,0),
				Vector2i(0,1)
			]:

				var target = current + direction

				if target.x >= BOARD_SIZE or target.y >= BOARD_SIZE:
					continue


				_swap_data(current,target)


				var possible = _has_any_match()


				_swap_data(current,target)


				if possible:
					return true


	return false


func _swap_data(a:Vector2i,b:Vector2i):

	var temp = board[a.y][a.x]

	board[a.y][a.x] = board[b.y][b.x]

	board[b.y][b.x] = temp
	
	
func _lose():

	$GamePanel/Status.text = "Ethan's trail has gone cold..."

	await get_tree().create_timer(1.0).timeout

	get_tree().change_scene_to_file(
		"res://scenes/FailureScene.tscn"
	)
