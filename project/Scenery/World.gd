extends Node2D

enum WallTiles {HORIZONTAL, BL_CORNER, BR_CORNER, TR_CORNER, TL_CORNER, LEFT, RIGHT}
enum FloorTiles {FLOOR}
enum Connections {NONE, TOP, BOTTOM, LEFT, RIGHT}

const ROOM_SIZE := 9
const EMPTY := -1
const VECTOR_TO_CONNECTION := {Vector2.UP:Connections.BOTTOM, Vector2.DOWN:Connections.TOP, Vector2.LEFT:Connections.RIGHT, Vector2.RIGHT:Connections.LEFT}

var _current_room_position := Vector2.ZERO
var _previous_room_position = null

onready var _walls = $Walls as TileMap
onready var _floors = $Floor as TileMap
onready var _animation_player = $AnimationPlayer as AnimationPlayer
onready var _blackout = $Blackout as Sprite


func _ready()->void:
	_blackout.scale *= ROOM_SIZE
	_create_room()


func _create_room(at := Vector2.ZERO, side_connected := Connections.NONE)->void:
	at *= ROOM_SIZE
	for x in ROOM_SIZE:
		for y in ROOM_SIZE:
			if y != 0:
				_floors.set_cell(x + at.x, y + at.y, FloorTiles.FLOOR)
			else:
				_floors.set_cell(x + at.x, y + at.y, EMPTY)
			# set up walls
			if x == 0 and y == 0:
				_walls.set_cell(x + at.x, y + at.y, WallTiles.TL_CORNER)
			elif x == 0 and y == ROOM_SIZE - 1:
				_walls.set_cell(x + at.x, y + at.y, WallTiles.BL_CORNER)
			elif x == ROOM_SIZE - 1 and y == 0:
				_walls.set_cell(x + at.x, y + at.y, WallTiles.TR_CORNER)
			elif x == ROOM_SIZE - 1 and y == ROOM_SIZE - 1:
				_walls.set_cell(x + at.x, y + at.y, WallTiles.BR_CORNER)
			elif x == 0:
				_walls.set_cell(x + at.x, y + at.y, WallTiles.LEFT)
			elif x == ROOM_SIZE - 1:
				_walls.set_cell(x + at.x, y + at.y, WallTiles.RIGHT)
			elif y == 0 or y == ROOM_SIZE - 1:
				_walls.set_cell(x + at.x, y + at.y, WallTiles.HORIZONTAL)
	if side_connected != Connections.NONE:
		_create_door_in_room(at, side_connected)


func _create_door_in_room(at:Vector2, side:int)->void:
	var door_position := Vector2.ZERO
	# warning-ignore:integer_division
	var door_offset := ROOM_SIZE / 2
	match side:
		Connections.TOP:
			door_position = Vector2(
				at.x + door_offset,
				at.y
			)
			_walls.set_cellv(door_position + Vector2.UP, EMPTY)
			_walls.set_cellv(door_position + Vector2.RIGHT, WallTiles.BL_CORNER)
			_walls.set_cellv(door_position + Vector2.RIGHT + Vector2.UP, WallTiles.TL_CORNER)
			_walls.set_cellv(door_position + Vector2.LEFT, WallTiles.BR_CORNER)
			_walls.set_cellv(door_position + Vector2.LEFT + Vector2.UP, WallTiles.TR_CORNER)
			_floors.set_cellv(door_position, FloorTiles.FLOOR)
		Connections.BOTTOM:
			door_position = Vector2(
				at.x + door_offset,
				at.y + ROOM_SIZE - 1
			)
			_walls.set_cellv(door_position + Vector2.DOWN, EMPTY)
			_walls.set_cellv(door_position + Vector2.RIGHT, WallTiles.TL_CORNER)
			_walls.set_cellv(door_position + Vector2.RIGHT + Vector2.DOWN, WallTiles.BL_CORNER)
			_walls.set_cellv(door_position + Vector2.LEFT, WallTiles.TR_CORNER)
			_walls.set_cellv(door_position + Vector2.LEFT + Vector2.DOWN, WallTiles.BR_CORNER)
			_floors.set_cellv(door_position + Vector2.DOWN, FloorTiles.FLOOR)
		Connections.LEFT:
			door_position = Vector2(
				at.x,
				at.y + door_offset
			)
			_walls.set_cellv(door_position + Vector2.LEFT, EMPTY)
		Connections.RIGHT:
			door_position = Vector2(
				at.x + ROOM_SIZE - 1,
				at.y + door_offset
			)
			_walls.set_cellv(door_position + Vector2.RIGHT, EMPTY)
	_walls.set_cellv(door_position, EMPTY)


func _delete_room(at:Vector2)->void:
	at *= ROOM_SIZE
	_blackout.position = at * 32
	_animation_player.play("Blackout")
	
	yield(_animation_player, "animation_finished")
	
	for x in ROOM_SIZE:
		for y in ROOM_SIZE:
			_floors.set_cell(x + at.x, y + at.y, EMPTY)
			_walls.set_cell(x + at.x, y + at.y, EMPTY)
	
	_blackout.modulate = Color(1, 1, 1, 0)


func _on_Main_ten_second_mark()->void:
	# a list of all spaces next to current room
	var next_room_position_options := [
		_current_room_position + Vector2.UP,
		_current_room_position + Vector2.DOWN,
		_current_room_position + Vector2.LEFT,
		_current_room_position + Vector2.RIGHT
	]
	# get rid of old room
	if _previous_room_position != null:
		_delete_room(_previous_room_position)
		# and make sure a new room does not appear in its space
		next_room_position_options.erase(_previous_room_position)
	# create the new room
	var next_room_position = next_room_position_options[randi() % next_room_position_options.size()] as Vector2
	_create_room(_current_room_position)
	_create_room(next_room_position, VECTOR_TO_CONNECTION[next_room_position - _current_room_position])
	_previous_room_position = _current_room_position
	_current_room_position = next_room_position
