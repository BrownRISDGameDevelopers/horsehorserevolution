extends Node2D

@export var merge_type: Global.MergeType = Global.MergeType.TUTORIAL
@export var song: Song
@export var in_charter: bool = true

@onready var road0 = $Road0
@onready var road1 = $Road1

var sync_phase: bool = false
var sync_health_tracker: Dictionary = {}

signal refresh_health
signal sync_slip

func _ready():
	Global.beat.connect(_on_conductor_beat)
	Global.note_hit.connect(manage_sync_health)
	road0.set_merge_type(merge_type)
	road1.set_merge_type(merge_type)

func play_from_beat(start_beat = 1):
	$Conductor.stream = song.song_stream
	$Conductor.set_bpm(song.bpm)
	$Conductor.play_from_position(start_beat, song.start_offset)
	road0.update_bpm(song.bpm)
	road1.update_bpm(song.bpm)

func manage_sync_health(player, area, _score, beat):
	if beat in sync_health_tracker:
		if player == Global.PlayerEnum.PLAYER_1:
			area *= -1
		var old_stats = sync_health_tracker[beat]
		var current_stats = [old_stats[0] - 1, old_stats[1] + area, old_stats[2]]
		if current_stats[0] == 0 and abs(current_stats[1]) > current_stats[2]:
			sync_slip.emit()
		sync_health_tracker[beat] = current_stats

func _on_conductor_beat(beat_position):
	var notes = song.get_notes(beat_position)
	var note_count = len(notes)
	var beat_adj = song.get_beat_adj(beat_position)
	if song.synced(beat_adj):
		sync_health_tracker[beat_adj] = [note_count, 0, note_count]
	for note in notes:
		_spawn_note(note.player, note.direction, note.duration, beat_adj)
	if sync_phase == false and song.synced(beat_position + 2):
		road0.enter_sync()
		road1.enter_sync()
		sync_phase = true
	elif sync_phase and not song.synced(beat_position + 2):
		road0.exit_sync()
		road1.exit_sync()
		refresh_health.emit()
		sync_phase = false
	if beat_position >= song.end_beat:
		Global.level_over.emit()

func _spawn_note(player: Global.PlayerEnum, direction: Global.Direction, duration, beat_position):
	if player == Global.PlayerEnum.PLAYER_1:
		road0.spawn_note(direction, duration, beat_position)
	else:
		road1.spawn_note(direction, duration, beat_position)
