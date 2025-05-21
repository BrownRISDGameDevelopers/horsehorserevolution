extends Control

@export var song: Song
@export var notes_display: VBoxContainer
@export var play_button: TextureButton
@export var song_progress: HSlider
@export var stage_select: GridContainer
@export var bpm_input: SpinBox
@export var offset_input: SpinBox
@export var controls: Node2D
@export var json_path: String

var max_beat = 0

var playing_chart = false

func _ready():
	Global.level_over.connect(stop_playback)

func _process(delta):
	if Input.is_action_pressed("escape"):
		stop_playback()

func set_playback_visibility():
	notes_display.visible = not playing_chart
	controls.modulate = "ffffff" if playing_chart else "666666"
	$CharterBody/CharterUI.process_mode = Node.PROCESS_MODE_DISABLED if playing_chart else Node.PROCESS_MODE_ALWAYS
	play_button.process_mode = Node.PROCESS_MODE_DISABLED if playing_chart else Node.PROCESS_MODE_ALWAYS
	song_progress.process_mode = Node.PROCESS_MODE_DISABLED if playing_chart else Node.PROCESS_MODE_ALWAYS

func stop_playback():
	playing_chart = false
	set_playback_visibility()
	controls.stop_playback()

func jsonify_song():
	var song_json = {}
	song_json["song_path"] = song.song_stream.resource_path
	song_json["bpm"] = bpm_input.value
	song_json["notes"] = notes_display.notes
	song_json["end_beat"] = song_progress.max_value + 4
	return song_json

func update_bpm(bpm):
	max_beat = song.song_stream.get_length() * bpm / 60

func load_json(song_json):
	song.parse_notes_from_dict(song_json)
	bpm_input.value = song.bpm
	offset_input.value = song.ms_before_start
	update_bpm(song.bpm)
	song_progress.max_value = max_beat - 4
	song_progress.value = 1
	notes_display.notes = song_json["notes"]
	notes_display.scroll_to(1)

func _on_export_button_pressed():
	var file = FileAccess.open(json_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(jsonify_song()))


func _on_play_button_pressed():
	playing_chart = true
	song.parse_notes_from_dict(jsonify_song())
	controls.play_from_beat(int(song_progress.value))
	set_playback_visibility()


func _on_song_upload_file_selected(path):
	var song_json = song.read_json_file(path)
	load_json(song_json)


func _on_song_progress_value_changed(value):
	notes_display.scroll_to(int(value))


func _on_notes_display_scroll_down():
	song_progress.value -= 1


func _on_notes_display_scroll_up():
	song_progress.value += 1


func _on_open_file_pressed():
	$SongUpload.visible = true


func _on_bpm_input_value_changed(value):
	update_bpm(value)
