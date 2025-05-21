extends Control

@export var song: Song
@export var notes_display: VBoxContainer
@export var song_progress: HSlider
@export var json_path: String

var max_beat = 0

var playing_chart = false
var controls
var controls_scene = preload("res://scenes/game_scene/game_content/controls.tscn")

func _ready():
	var song_json = song.read_json_file(json_path)
	song.parse_notes_from_dict(song_json)
	notes_display.notes = song_json["notes"]
	notes_display.scroll_to(1)
	Global.beat.connect(end_playback)

func _process(delta):
	pass
	# $HBoxContainer.visible = not playing_chart
	# if Input.is_action_pressed("escape"):
	# 	stop_controls()

func end_playback(beat):
	if beat >= song.end_beat:
		stop_controls()

func stop_controls():
	playing_chart = false
	if controls:
		controls.queue_free()

func jsonify_song():
	var song_json = {}
	song_json["song_path"] = song.song_stream.resource_path
	song_json["bpm"] = song.bpm
	song_json["notes"] = song.notes_list
	return song_json

func _on_export_button_pressed():
	var file = FileAccess.open(json_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(jsonify_song()))


func _on_file_dialog_file_selected(path: String):
	json_path = "res://assets/chart/" + $FileDialog.current_file
	song.parse_notes_from_dict(song.read_json_file(json_path))
	notes_display.song = song


func _on_play_button_pressed():
	song.parse_notes_from_dict(jsonify_song())
	controls = controls_scene.instantiate()
	controls.position = Vector2(960, 540)
	controls.scale = Vector2(5, 5)
	controls.song = song
	add_child(controls)
	# controls.play_from_beat(int(beat_select.text))
	playing_chart = true


func _on_song_progress_value_changed(value):
	notes_display.scroll_to(int(value))


func _on_notes_display_scroll_down():
	song_progress.value -= 1


func _on_notes_display_scroll_up():
	song_progress.value += 1
