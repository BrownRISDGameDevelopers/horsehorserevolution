class_name Song
extends Node2D

@export var bpm = 120

@export var song_json_path: String = "res://Assets/test_song.json"

var notes_list: Dictionary = {}

var note_info_scene = preload("res://Scenes/NoteInfo.tscn")

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
	for beat in raw_notes_list:
		var beat_notes = []
		for note in raw_notes_list[beat]:
			var note_info: NoteInfo = note_info_scene.instantiate()
			note_info.initialize(note["player"], note["direction"])
			beat_notes.append(note_info)
		notes_list[int(beat)] = beat_notes

func get_notes(beat: int):
	if beat not in notes_list:
		return []
	return notes_list[beat]
