extends Node2D

@export var player_num: Global.PlayerEnum
var bpm = 120

var note = load("res://scenes/game_scene/game_content/note.tscn")

@onready var road = $RoadSprite
@onready var left = %ArrowLeft
@onready var down = %ArrowDown
@onready var up = %ArrowUp
@onready var right = %ArrowRight

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	left.update_player(player_num)
	down.update_player(player_num)
	up.update_player(player_num)
	right.update_player(player_num)


func set_merge_type(merge_type: Global.MergeType):
	if merge_type == Global.MergeType.COUNTRY:
		%CountryMerge.visible = true
	elif merge_type == Global.MergeType.DISCO:
		%DiscoMerge.visible = true
	elif merge_type == Global.MergeType.DEATHMETAL:
		%DeathMetalMerge.visible = true


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

func spawn_note(direction, duration, beat_position):
	var instance = note.instantiate()
	road.add_child(instance)
	instance.initialize(duration, bpm, player_num, left.position.y, beat_position)
	instance.set_direction(direction)


func destroy_notes():
	for child in road.get_children():
		if child is Area2D:
			child.queue_free()