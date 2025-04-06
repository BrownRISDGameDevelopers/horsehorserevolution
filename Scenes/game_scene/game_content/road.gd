extends Node2D

@export var road_num: int
var bpm = 120
var sync_phase: bool = false

var note = load("res://scenes/game_scene/game_content/note.tscn")
var dance_bar1: TextureProgressBar
var dance_bar2: TextureProgressBar

@onready var road = $RoadSprite
@onready var left = $RoadSprite/ArrowLeft
@onready var down = $RoadSprite/ArrowDown
@onready var up = $RoadSprite/ArrowUp
@onready var right = $RoadSprite/ArrowRight

@onready var anim: AnimationPlayer = $AnimationPlayer

var game_obj

func _ready():
	game_obj = get_parent()
	left.update_player(road_num, game_obj)
	down.update_player(road_num, game_obj)
	up.update_player(road_num, game_obj)
	right.update_player(road_num, game_obj)

func enter_sync():
	if (road_num == 1):
		anim.play("enter_sync_right")
	else:
		anim.play("enter_sync_left")
	
func exit_sync():
	if (road_num == 1):
		anim.play("exit_sync_right")
	else:
		anim.play("exit_sync_left")

func update_bpm(new_bpm):
	bpm = new_bpm

func initialize(new_bpm, db1, db2):
	bpm = new_bpm
	dance_bar1 = db1
	dance_bar2 = db2

func spawn_note(direction, duration):
	var instance = note.instantiate()
	road.add_child(instance)
	instance.initialize(duration, bpm, road_num, dance_bar1, dance_bar2, left.position.y)
	instance.set_direction(direction)

func reset_combo():
	game_obj.reset_combo()
