extends Node2D

@export var song: Song
@export var notes_list: VBoxContainer
@export var JSONOutputPath: String = "res://assets/chart/test_song.json"

var beat_ui = load("res://scenes/menu_scene/charter/charter_component/beat_ui.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var sorted_notes = []
	for note in song.notes_list:
		sorted_notes.append([note, song.notes_list[note]])
	sorted_notes.sort()
	for note in sorted_notes:
		var beat = beat_ui.instantiate()
		beat.init_beat(note[0], str(note[0]) in song.synced_notes)
		beat.set_toggle(note[1])
		notes_list.add_child(beat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_export_button_pressed():
	var song_json = {}
	song_json["bpm"] = song.bpm
	song_json["notes"] = {}
	for beat in notes_list.get_children():
		song_json["notes"][beat.beat_no] = beat.get_note_info()
	var file = FileAccess.open(JSONOutputPath, FileAccess.WRITE)
	file.store_line(JSON.stringify(song_json))
