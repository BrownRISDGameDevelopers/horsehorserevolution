class_name NoteInfo
extends Node2D

enum Player {PLAYER_1, PLAYER_2}
enum Direction {LEFT, DOWN, UP, RIGHT}

@export var player: Player
@export var direction: Direction

func initialize(p, d):
    player = p
    direction = d

func get_lane():
    return player * 4 + direction
