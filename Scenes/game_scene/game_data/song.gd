class_name Song
extends Node2D

@export var song_json_path: String = "res://assets/chart/test_song.json"
@export var song_stream: AudioStream
@export var end_offset = 0
@export var start_offset = 6

var ms_before_start = 0
var bpm = 120
var end_beat: int = 0

var notes_list: Dictionary = {}
var synced_notes: Dictionary = {}
var notes_with_duration: Dictionary = {}

var note_info_scene = preload("res://scenes/game_scene/game_data/note_info.tscn")

func read_json_file(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content_as_text = file.get_as_text()
	var content_as_dictionary = JSON.parse_string(content_as_text)
	return content_as_dictionary

func parse_notes_from_dict(song_info):
	notes_list = {}
	synced_notes = {}
	notes_with_duration = {}
	var raw_notes_list = song_info["notes"]
	if "song_path" in song_info:
		song_stream = load(song_info["song_path"])
	bpm = song_info["bpm"]
	var prev_notes = {}
	var sorted_beats = raw_notes_list.keys()
	var sort_ascending = func(a, b):
		return int(a) < int(b)
	sorted_beats.sort_custom(sort_ascending)
	for beat in sorted_beats:
		var cur_notes = {}
		var beat_notes = []
		if raw_notes_list[beat]["sync"]:
			synced_notes[beat] = true
		for note in raw_notes_list[beat]["arrows"]:
			var note_info: NoteInfo = note_info_scene.instantiate()
			note_info.initialize(note["player"], note["direction"], note["held"])
			if note_info.get_uid() in prev_notes and note["held"]:
				cur_notes[note_info.get_uid()] = prev_notes[note_info.get_uid()]
				prev_notes.erase(note_info.get_uid())
				cur_notes[note_info.get_uid()].increment_duration()
			else:
				cur_notes[note_info.get_uid()] = note_info
			beat_notes.append(note_info)
		for note in prev_notes:
			var start_beat = int(beat) - prev_notes[note].duration
			if start_beat in notes_with_duration:
				notes_with_duration[start_beat].append(prev_notes[note])
			else:
				notes_with_duration[start_beat] = [prev_notes[note]]
		prev_notes = cur_notes
		notes_list[int(beat)] = beat_notes
		end_beat = max(end_beat, int(beat))
	if "end_beat" in song_info:
		end_beat = song_info["end_beat"]

func _ready():
	var song_info = read_json_file(song_json_path)
	parse_notes_from_dict(song_info)

func get_beat_adj(beat: int):
	return beat + start_offset - 1

func get_notes(beat: int):
	var beat_adj = get_beat_adj(beat)
	if beat_adj not in notes_with_duration:
		return []
	var notes = notes_with_duration[beat_adj]
	return notes

func synced(beat):
	var beat_adj
	if type_string(typeof(beat)) == "int":
		beat_adj = beat
	else:
		beat_adj = int(beat)
	return beat_adj in synced_notes or str(beat_adj) in synced_notes
