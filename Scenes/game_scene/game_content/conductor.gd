extends AudioStreamPlayer

@export var bpm := 120

# Tracking the beat and song position
var ingame_time: float = 0.0
var time_start: float = 100.0
var song_position_in_beats = -100

var start_position = 0
var start_offset = 0
var start_in_seconds = 0.0
var currently_playing = false
var playback_started = false

var sec_per_beat: float:
	get:
		return 60.0 / bpm
var last_reported_beat = -100

func set_bpm(new_bpm):
	bpm = new_bpm

func _physics_process(delta):
	if currently_playing:
		ingame_time += delta
		song_position_in_beats = floor((ingame_time - time_start) / sec_per_beat) + start_offset
		if not playback_started:
			var playback_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
			if floor((ingame_time - time_start + playback_delay) / sec_per_beat) + start_offset >= start_position:
				play(start_in_seconds)
				playback_started = true
		_report_beat()

func _report_beat():
	if last_reported_beat < song_position_in_beats:
		last_reported_beat = song_position_in_beats
		Global.beat.emit(song_position_in_beats)

func play_from_position(position, offset):
	start_in_seconds = (position - 1) * sec_per_beat
	start_position = position - 1
	start_offset = position - offset
	time_start = Time.get_ticks_msec() / 1000.0
	ingame_time = time_start
	currently_playing = true

func stop_playback():
	currently_playing = false
	stop()