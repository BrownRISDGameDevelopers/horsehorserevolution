extends Control

@export var song: Song
@export var notes_container: ScrollContainer
@export var notes_list: VBoxContainer
@export var beat_select: OptionButton
@export var json_path: String

var beat_ui = load("res://scenes/charter/charter_component/beat_ui.tscn")
var max_beat = 0

var playing_chart = false
var controls
var controls_scene = preload("res://scenes/game_scene/game_content/controls.tscn")

func _ready():
	Global.beat.connect(end_playback)

func _process(delta):
	$HBoxContainer.visible = not playing_chart
	if Input.is_action_pressed("escape"):
		stop_controls()

func end_playback(beat):
	if beat >= song.end_beat:
		stop_controls()

func stop_controls():
		playing_chart = false
		if controls:
			controls.queue_free()

func jsonify_song():
	var song_json = {}
	var end_beat = -1
	song_json["song_path"] = song.song_stream.resource_path
	song_json["bpm"] = song.bpm
	song_json["notes"] = {}
	for beat in notes_list.get_children():
		if beat.has_beat_info():
			song_json["notes"][beat.beat_no] = beat.get_note_info()
			if beat.ends_song():
				end_beat = max(end_beat, beat.beat_no)
	if end_beat > -1:
		song_json["end_beat"] = end_beat
	return song_json

func _on_export_button_pressed():
	var file = FileAccess.open(json_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(jsonify_song()))


func _on_file_dialog_file_selected(path: String):
	json_path = "res://assets/chart/" + $FileDialog.current_file
	song.parse_notes_from_dict(song.read_json_file(json_path))
	var sorted_notes = []
	for note in song.notes_list:
		beat_select.add_item(str(note))
		sorted_notes.append([note, song.notes_list[note]])
	var sort_descending = func(a, b):
		return a > b
	sorted_notes.sort_custom(sort_descending)
	for note in sorted_notes:
		var beat = beat_ui.instantiate()
		max_beat = max(max_beat, note[0])
		if note[0] == song.end_beat:
			beat.set_ending()
		beat.init_beat(note[0], str(note[0]) in song.synced_notes)
		beat.set_toggle(note[1])
		notes_list.add_child(beat)
	await notes_container.get_v_scroll_bar().changed
	notes_container.scroll_vertical = notes_container.get_v_scroll_bar().max_value


func _on_play_button_pressed():
	song.parse_notes_from_dict(jsonify_song())
	controls = controls_scene.instantiate()
	controls.position = Vector2(960, 540)
	controls.scale = Vector2(5, 5)
	controls.song = song
	add_child(controls)
	controls.play_from_beat(int(beat_select.text))
	playing_chart = true


func _on_add_beat_pressed():
	max_beat += 1
	var beat = beat_ui.instantiate()
	beat.init_beat(max_beat, false)
	$HBoxContainer/NotesContainer/NotesList/AddBeat.add_sibling(beat)
