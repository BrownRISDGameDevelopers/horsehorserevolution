extends Node2D

@export var song: Song
@export var notes_container: ScrollContainer
@export var notes_list: VBoxContainer
@export var json_path: String

var beat_ui = load("res://scenes/menu_scene/charter/charter_component/beat_ui.tscn")

func _on_export_button_pressed():
	var song_json = {}
	song_json["bpm"] = song.bpm
	song_json["notes"] = {}
	for beat in notes_list.get_children():
		song_json["notes"][beat.beat_no] = beat.get_note_info()
	var file = FileAccess.open(json_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(song_json))


func _on_file_dialog_file_selected(path: String):
	json_path = "res://assets/chart/" + $FileDialog.current_file
	song.song_json_path = json_path
	song.initialize()
	var sorted_notes = []
	for note in song.notes_list:
		sorted_notes.append([note, song.notes_list[note]])
	var sort_descending = func(a, b):
		if a > b:
			return true
		return false
	sorted_notes.sort_custom(sort_descending)
	for note in sorted_notes:
		var beat = beat_ui.instantiate()
		beat.init_beat(note[0], str(note[0]) in song.synced_notes)
		beat.set_toggle(note[1])
		notes_list.add_child(beat)
	await notes_container.get_v_scroll_bar().changed
	notes_container.scroll_vertical = notes_container.get_v_scroll_bar().max_value