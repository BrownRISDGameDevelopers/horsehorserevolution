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

@onready var road0 = $Road0
@onready var road1 = $Road1

@onready var dance_bar_node: Node2D = $DanceBar
@onready var dance_bar1: TextureProgressBar = dance_bar_node.get_node("TextureProgressBar1")
@onready var dance_bar2: TextureProgressBar = dance_bar_node.get_node("TextureProgressBar2")

var sync_phase: bool = false
var sync_health: int = 3
var player1hit: int = -1
var player2hit: int = -1

func _ready():
	$Conductor.set_bpm(song.bpm)
	$Conductor.play_with_beat_offset(song.start_offset)
	road0.initialize(song.bpm, dance_bar1, dance_bar2)
	road1.initialize(song.bpm, dance_bar1, dance_bar2)
	Global.measure.connect(_on_Conductor_measure)
	Global.beat.connect(_on_Conductor_beat)


func _input(event):
	if event.is_action("escape"):
		if get_tree().change_scene_to_file("res://scenes/menu_scene/menu.tscn") != OK:
			print("Error changing scene to Menu")


func _on_Conductor_measure(position):
	pass

func _on_Conductor_beat(position):
	var notes = song.get_notes(position)
	for note in notes:
		_spawn_note(note.get_lane(), note.duration)
	if sync_phase == false and str(position) in song.synced_notes:
		road0.enter_sync()
		road1.enter_sync()
		sync_phase = true
	elif sync_phase and str(position) not in song.synced_notes:
		road0.exit_sync()
		road1.exit_sync()
		sync_phase = false
	if position > song.end_beat:
		Global.set_score(score)
		Global.combo = max_combo
		Global.great = great
		Global.good = good
		Global.okay = okay
		Global.missed = missed
		if get_tree().change_scene_to_file("res://scenes/menu_scene/end.tscn") != OK:
			print("Error changing scene to End")


func _spawn_note(lane: Vector2, duration):
	var player = lane.x
	var direction = lane.y

	if player == 0:
		road0.spawn_note(direction, duration)
	else:
		road1.spawn_note(direction, duration)
		
func set_player1hit(areaNum):
	player1hit = areaNum
	#print(player2hit)
	if player2hit != 0:
		if sync_phase:
			if abs(player1hit - player2hit) > 2:
				sync_health -= 1
				print(sync_health)
		player1hit = 0
		player2hit = 0

func set_player2hit(areaNum):
	player2hit = areaNum
	#print(player1hit)
	if player1hit != 0:
		if sync_phase:
			if abs(player1hit - player2hit) > 2:
				sync_health -= 1
				print(sync_health)
		player1hit = 0
		player2hit = 0

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
	
	# if dance_bar1.value == 0 or dance_bar2.value == 200:
	# 	game_over()
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
	if get_tree().change_scene_to_file("res://scenes/menu_scene/game_over.tscn") != OK:
		print("Error changing scene to Game Over")


func reset_combo():
	combo = 0
	$Combo.text = ""
