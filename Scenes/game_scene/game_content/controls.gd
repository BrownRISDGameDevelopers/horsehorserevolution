extends Node2D

@export var song: Song
@export var in_charter: bool = true

var score = 0
var combo = 0

var max_combo = 0
var great = 0
var good = 0
var okay = 0
var missed = 0

@onready var road0 = $Road0
@onready var road1 = $Road1

var sync_phase: bool = false

func _ready():
	if not in_charter:
		$Conductor.set_bpm(song.bpm)
		$Conductor.play_with_offset(song.start_offset)
	road0.update_bpm(song.bpm)
	road1.update_bpm(song.bpm)

func set_song_from_charter(song_file_path):
	$Conductor.stream = load(song_file_path)

func play_from_charter(start_beat):
	$Conductor.set_bpm(song.bpm)
	$Conductor.play_from_position(start_beat, song.start_offset)
	road0.update_bpm(song.bpm)
	road1.update_bpm(song.bpm)

func _on_conductor_beat(position):
	var notes = song.get_notes(position)
	for note in notes:
		_spawn_note(note.player, note.direction, note.duration)
	if sync_phase == false and song.synced(position):
		road0.enter_sync()
		road1.enter_sync()
		sync_phase = true
	elif sync_phase and not song.synced(position):
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


func _spawn_note(player: Global.PlayerEnum, direction: Global.Direction, duration):
	if player == Global.PlayerEnum.PLAYER_1:
		road0.spawn_note(direction, duration)
	else:
		road1.spawn_note(direction, duration)
