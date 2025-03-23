class_name NoteInfo
extends Node2D

enum Player {PLAYER_1, PLAYER_2}
enum Direction {LEFT, DOWN, UP, RIGHT}

@export var player: Player
@export var direction: Direction
@export var held: bool
@export var duration: int = 1

func initialize(p, d, h):
	player = p
	direction = d
	held = h

func increment_duration():
	duration += 1

func get_lane():
	return Vector2(player, direction)

func get_uid():
	return "Player" + str(player + 1) + ["Left", "Down", "Up", "Right"][direction]

func get_held():
	return held
