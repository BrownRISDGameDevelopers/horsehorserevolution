extends Control

@export var song: Song
@export var notes_display: VBoxContainer
@export var play_button: TextureButton
@export var song_progress: HSlider
@export var stage_select: ButtonGroup
@export var bpm_input: SpinBox
@export var controls: Node2D

var max_beat = 0

var audio_path: String
var json_path: String
@export var stage_correspondence: Dictionary[String, Button]

var progress_bookmark = 0
var playing_chart = false

var popup_open
@export_file("*.tscn") var main_menu_scene: String

func _ready():
	Global.level_over.connect(stop_playback)

func _process(delta):
	if Input.is_action_pressed("escape"):
		stop_playback()
	if playing_chart:
		song_progress.set_value_no_signal(song_progress.value + song.bpm / 60.0 * delta)

func _on_play_button_pressed():
	playing_chart = true
	progress_bookmark = song_progress.value
	song.parse_notes_from_dict(jsonify_song())
	controls.play_from_beat(int(song_progress.value))
	set_playback_visibility()
	song_progress.set_value_no_signal(song_progress.value - song.start_offset)

func set_playback_visibility():
	notes_display.visible = not playing_chart
	controls.modulate = "ffffff" if playing_chart else "666666"
	$CharterBody/CharterUI.process_mode = Node.PROCESS_MODE_DISABLED if playing_chart else Node.PROCESS_MODE_ALWAYS
	play_button.process_mode = Node.PROCESS_MODE_DISABLED if playing_chart else Node.PROCESS_MODE_ALWAYS
	song_progress.process_mode = Node.PROCESS_MODE_DISABLED if playing_chart else Node.PROCESS_MODE_ALWAYS
	song_progress.rounded = not playing_chart
	song_progress.allow_lesser = playing_chart
	song_progress.step = 0.0 if playing_chart else 1.0

func stop_playback():
	playing_chart = false
	song_progress.value = progress_bookmark
	set_playback_visibility()
	controls.stop_playback()


func jsonify_song():
	var song_json = {}
	song_json["stage"] = stage_select.get_pressed_button().text
	song_json["bpm"] = bpm_input.value
	song_json["notes"] = notes_display.notes
	song_json["end_beat"] = int(max_beat)
	return song_json


func _on_open_file_pressed():
	%ErrorMessage.visible = false
	$SongUpload.visible = true

func _on_song_upload_file_selected(path: String):
	var ext = path.to_lower().get_extension()
	if ext == "json":
		load_json(path)
	elif ext == "zip":
		load_zip(path)
	else:
		load_audio(path)

func load_json(path):
	var song_json = song.read_json_file(path)
	song.parse_notes_from_dict(song_json)
	notes_display.notes = song_json["notes"]
	update_charter()

func load_zip(path):
	var reader = ZIPReader.new()
	var err = reader.open(path)
	if err != OK:
		return PackedByteArray()
	var files = reader.get_files()
	var song_json
	var user_sound
	for file in files:
		var ext = file.get_extension()
		var bytes: PackedByteArray = reader.read_file(file)
		if ext == "json":
			song_json = JSON.parse_string(bytes.get_string_from_utf8())
		elif ext == "wav":
			user_sound = AudioStreamWAV.load_from_buffer(bytes)
		elif ext == "ogg":
			user_sound = AudioStreamOggVorbis.load_from_buffer(bytes)
		elif ext == "mp3":
			user_sound = AudioStreamMP3.load_from_buffer(bytes)
	reader.close()
	if song_json != null and user_sound != null:
		song.parse_notes_from_dict(song_json)
		notes_display.notes = song_json["notes"]
		print(song_json["stage"])
		stage_correspondence[song_json["stage"]].button_pressed = true
		song.song_stream = user_sound
		update_charter()
	else:
		%ErrorMessage.visible = true

func load_audio(path):
	var ext = path.to_lower().get_extension()
	var user_sound: AudioStream = null
	if ext == "wav":
		user_sound = AudioStreamWAV.load_from_file(path)
	elif ext == "ogg":
		user_sound = AudioStreamOggVorbis.load_from_file(path)
	elif ext == "mp3":
		user_sound = AudioStreamMP3.load_from_file(path)
	if user_sound != null:
		audio_path = path
		song.song_stream = user_sound
		update_charter()
	else:
		%ErrorMessage.visible = true


func _on_bpm_input_value_changed(value):
	update_bpm(value)

func update_charter():
	bpm_input.value = song.bpm
	update_bpm(song.bpm)
	song_progress.max_value = max_beat - 4
	song_progress.value = 1
	notes_display.scroll_to(1)

func update_bpm(bpm):
	max_beat = song.song_stream.get_length() * bpm / 60


func _on_export_button_pressed():
	$LevelExport.visible = true

func _on_level_export_file_selected(path: String):
	var writer = ZIPPacker.new()
	var err = writer.open(path)
	if err != OK:
		return err
	writer.start_file("chart.json")
	writer.write_file(JSON.stringify(jsonify_song()).to_utf8_buffer())
	writer.start_file("song" + "." + audio_path.get_extension())
	writer.write_file(FileAccess.get_file_as_bytes(audio_path))
	writer.close_file()


func _on_song_progress_value_changed(value):
	notes_display.scroll_to(int(value))

func _on_notes_display_scroll_down():
	song_progress.value -= 1

func _on_notes_display_scroll_up():
	song_progress.value += 1


func _handle_cancel_input():
	if popup_open != null:
		close_popup()

func _on_main_menu_button_pressed():
	%ConfirmMainMenu.popup_centered()
	popup_open = %ConfirmMainMenu

func close_popup():
	if popup_open != null:
		popup_open.hide()
		popup_open = null

func _on_confirm_main_menu_confirmed():
	SceneLoader.load_scene(main_menu_scene)
