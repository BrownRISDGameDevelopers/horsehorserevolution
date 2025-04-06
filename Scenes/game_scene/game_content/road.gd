extends Node2D

@export var player_num: Global.PlayerEnum
var bpm = 120
var sync_phase: bool = false

var note = load("res://scenes/game_scene/game_content/note.tscn")

@onready var road = $RoadSprite
@onready var left = $RoadSprite/ArrowLeft
@onready var down = $RoadSprite/ArrowDown
@onready var up = $RoadSprite/ArrowUp
@onready var right = $RoadSprite/ArrowRight

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	left.update_player(player_num)
	down.update_player(player_num)
	up.update_player(player_num)
	right.update_player(player_num)

func enter_sync():
	if (player_num == Global.PlayerEnum.PLAYER_2):
		anim.play("enter_sync_right")
	else:
		anim.play("enter_sync_left")
	
func exit_sync():
	if (player_num == Global.PlayerEnum.PLAYER_2):
		anim.play("exit_sync_right")
	else:
		anim.play("exit_sync_left")

func update_bpm(new_bpm):
	bpm = new_bpm

func spawn_note(direction, duration):
	var instance = note.instantiate()
	road.add_child(instance)
	instance.initialize(duration, bpm, player_num, left.position.y)
	instance.set_direction(direction)
