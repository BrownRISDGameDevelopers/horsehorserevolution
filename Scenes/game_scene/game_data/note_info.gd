class_name NoteInfo
extends Node2D

@export var player: Global.PlayerEnum
@export var direction: Global.Direction
@export var held: bool
@export var duration: int = 1

func initialize(p, d, h):
	player = p
	direction = d
	held = h

func increment_duration():
	duration += 1

func get_uid():
	return "Player" + str(player + 1) + ["Left", "Down", "Up", "Right"][direction]

func get_held():
	return held
