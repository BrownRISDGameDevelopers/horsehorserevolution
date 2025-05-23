extends Node2D

@export var MidiSourcePath: String = "res://assets/audio/hhr-tutorialbeat.mid"
@export var JSONOutputPath: String = "res://assets/chart/test_song.json"


var ms_per_tick = 60000 / (120 * 480)
var audio_streams = {}
var phase = 0.0
var parser
var ticks = 0
var bpm = 120
var bpm_set = false

# Called when the node enters the scene tree for the first time.
func _ready():
	parser = MidiFileParser.load_file(MidiSourcePath)
	var song_json = {}
	song_json["notes"] = {}
	var end_beat = 0
	for track in parser.tracks:
		var delta_ms = 0
		var delta_ticks = 0
		var player_process
		# storing internal player process in track data
		if "player_process" not in track.additional_data:
			track.additional_data.player_process = {"time": Time.get_ticks_msec(), "event_index": 0}
			player_process = track.additional_data.player_process
		else:
			player_process = track.additional_data.player_process
			delta_ms = Time.get_ticks_msec() - player_process.time
			
		while player_process.event_index < track.events.size():
			var event = track.events[player_process.event_index]
			delta_ticks += event.delta_ticks
			player_process.event_index += 1
			player_process.time = Time.get_ticks_msec()
			delta_ms = 0
			# self.emit_signal("event", event, track)
			if event.event_type == MidiFileParser.Event.EventType.META && event.type == MidiFileParser.Meta.Type.SET_TEMPO:
				# tempo update
				ms_per_tick = event.ms_per_tick
				if not bpm_set:
					bpm_set = true
					bpm = event.bpm
			if event.event_type == event.EventType.MIDI && event.note_name != '':
				var offset = event.param1 - 69
				var event_ms = delta_ticks * ms_per_tick
				var event_beat = event_ms * bpm / 60000.0
				if event.velocity > 0:
					end_beat = max(event_beat, end_beat)
	song_json["bpm"] = bpm
	for i in range(ceil(end_beat)):
		song_json["notes"][str(i)] = {"sync": false, "arrows": [ {"direction": 0, "player": 0, "held": false}, {"direction": 0, "player": 1, "held": false}]}
	var file = FileAccess.open(JSONOutputPath, FileAccess.WRITE)
	file.store_line(JSON.stringify(song_json))
