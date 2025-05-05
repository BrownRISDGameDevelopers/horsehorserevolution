class_name NoteInfo
extends Node2D

var player: Global.PlayerEnum
var direction: Global.Direction
var held: bool
var duration: int = 1

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
