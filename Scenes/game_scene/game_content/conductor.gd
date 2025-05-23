extends AudioStreamPlayer

@export var bpm := 120

# Tracking the beat and song position
var song_position = 0.0
var song_position_in_beats = 1

var start_position = 0
var start_in_seconds = 0.0

var sec_per_beat: float:
	get:
		return 60.0 / bpm
var last_reported_beat = -100

# Determining how close to the beat an event is
var closest = 0
var time_off_beat = 0.0
var audio_latency

func set_bpm(new_bpm):
	bpm = new_bpm

func _ready():
	audio_latency = AudioServer.get_output_latency()


func _physics_process(_delta):
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= audio_latency
		song_position_in_beats = int(floor(song_position / sec_per_beat))
		_report_beat()

func _report_beat():
	if last_reported_beat < song_position_in_beats:
		last_reported_beat = song_position_in_beats
		Global.beat.emit(song_position_in_beats)

func play_from_position(position, offset):
	start_in_seconds = (position - 1) * sec_per_beat
	start_position = position - 1
	song_position_in_beats = position - offset
	$StartTimer.wait_time = sec_per_beat
	$StartTimer.start()

func _on_start_timer_timeout():
	song_position_in_beats += 1
	if song_position_in_beats >= start_position:
		play(start_in_seconds)
		$StartTimer.stop()
	elif song_position_in_beats < start_position - 1:
		$StartTimer.start()
	elif song_position_in_beats == start_position - 1:
		$StartTimer.wait_time = $StartTimer.wait_time - (AudioServer.get_time_to_next_mix() +
														audio_latency)
		$StartTimer.start()
	_report_beat()


func closest_beat(nth):
	closest = int(round((song_position / sec_per_beat) / nth) * nth)
	time_off_beat = abs(closest * sec_per_beat - song_position)
	return Vector2(closest, time_off_beat)
