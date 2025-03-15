extends Node2D

@export var song: Song

var score = 0
var combo = 0

var max_combo = 0
var great = 0
var good = 0
var okay = 0
var missed = 0

var spawn_1_beat = 0
var spawn_2_beat = 0
var spawn_3_beat = 1
var spawn_4_beat = 0

var lane = 0
var rand = 0
var note = load("res://Scenes/Note.tscn")
var instance
@onready var dance_bar_node: Node2D = $DanceBar
@onready var dance_bar1: TextureProgressBar = dance_bar_node.get_node("TextureProgressBar1")
@onready var dance_bar2: TextureProgressBar = dance_bar_node.get_node("TextureProgressBar2")

var sync_phase : bool = false

func _ready():
	$Conductor.set_bpm(song.bpm)
	$Conductor.play_with_beat_offset(8)
	Global.measure.connect(_on_Conductor_measure)
	Global.beat.connect(_on_Conductor_beat)


func _input(event):
	if event.is_action("escape"):
		if get_tree().change_scene_to_file("res://Scenes/Menu.tscn") != OK:
			print("Error changing scene to Menu")


func _on_Conductor_measure(position):
	pass

func _on_Conductor_beat(position):
	var notes = song.get_notes(position)
	for note in notes:
		_spawn_note(note.get_lane())
	if position > 404:
		Global.set_score(score)
		Global.combo = max_combo
		Global.great = great
		Global.good = good
		Global.okay = okay
		Global.missed = missed
		if get_tree().change_scene_to_file("res://Scenes/End.tscn") != OK:
			print("Error changing scene to End")


func _spawn_note(lane):
	instance = note.instantiate()
	#instance.initialize(lane)
	add_child(instance)
	instance.initialize(lane)
	if lane >= 4:
		instance.collision_layer = 0b0010
	instance.dance_bar1 = dance_bar1
	instance.dance_bar2 = dance_bar2

		
func increment_score(by):
	if by > 0:
		combo += 1
	else:
		combo = 0
	
	if by == 3:
		great += 1
		dance_bar1.value += 15
		dance_bar2.value -= 15
	elif by == 2:
		good += 1
		dance_bar1.value += 10
		dance_bar2.value -= 10
	elif by == 1:
		okay += 1
		dance_bar1.value += 5
		dance_bar2.value -= 5
	else:
		missed += 1
		dance_bar1.value -= 5
		dance_bar2.value += 5
	
	if dance_bar1.value == 0 or dance_bar2.value == 200:
		game_over()
	score += by * combo
	$Label.text = str(score)
	if combo > 0:
		$Combo.text = str(combo) + " combo!"
		if combo > max_combo:
			max_combo = combo
	else:
		$Combo.text = ""

func game_over():
	print("Game Over!")
	if get_tree().change_scene_to_file("res://Scenes/GameOver.tscn") != OK:
		print("Error changing scene to Game Over")


func reset_combo():
	combo = 0
	$Combo.text = ""
