extends Node2D

@export var merge_type: Global.MergeType = Global.MergeType.TUTORIAL
@export var song: Song
@export var in_charter: bool = true

@onready var road0 = $Road0
@onready var road1 = $Road1

var sync_phase: bool = false

func _ready():
	Global.beat.connect(_on_conductor_beat)
	road0.set_merge_type(merge_type)
	road1.set_merge_type(merge_type)

func play_from_beat(start_beat = 1):
	$Conductor.stream = song.song_stream
	$Conductor.set_bpm(song.bpm)
	$Conductor.play_from_position(start_beat, song.start_offset)
	road0.update_bpm(song.bpm)
	road1.update_bpm(song.bpm)

func _on_conductor_beat(beat_position):
	var notes = song.get_notes(beat_position)
	for note in notes:
		_spawn_note(note.player, note.direction, note.duration)
	if sync_phase == false and song.synced(beat_position):
		road0.enter_sync()
		road1.enter_sync()
		sync_phase = true
	elif sync_phase and not song.synced(beat_position):
		road0.exit_sync()
		road1.exit_sync()
		sync_phase = false
	if beat_position > song.end_beat:
		Global.level_over.emit()


func _spawn_note(player: Global.PlayerEnum, direction: Global.Direction, duration):
	if player == Global.PlayerEnum.PLAYER_1:
		road0.spawn_note(direction, duration)
	else:
		road1.spawn_note(direction, duration)
