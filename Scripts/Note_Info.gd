class_name NoteInfo
extends Node2D

enum Player {PLAYER_1, PLAYER_2}
enum Direction {LEFT, DOWN, UP, RIGHT}

@export var player: Player
@export var direction: Direction
@export var held: bool

func initialize(p, d, h):
	player = p
	direction = d
	held = h

func get_lane():
	return player * 4 + direction

func get_uid():
	return "Player" + str(player + 1) + ["Left", "Down", "Up", "Right"][direction]

func get_held():
	return held
