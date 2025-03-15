class_name Song
extends Node2D

@export var bpm = 120

@export var song_json_path: String = "res://assets/chart/test_song.json"

var notes_list: Dictionary = {}
var synced_notes: Dictionary = {}
var notes_with_duration: Dictionary = {}

var note_info_scene = preload("res://scenes/game_scene/game_data/note_info.tscn")

func parse_json(text):
	return JSON.parse_string(text)

func read_json_file(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content_as_text = file.get_as_text()
	var content_as_dictionary = parse_json(content_as_text)
	return content_as_dictionary

func _ready():
	var song_info = read_json_file(song_json_path)
	var raw_notes_list = song_info["notes"]
	bpm = song_info["bpm"]
	var prev_notes = {}
	for beat in raw_notes_list:
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

func get_notes(beat: int):
	if beat not in notes_with_duration:
		return []
	return notes_with_duration[beat]
