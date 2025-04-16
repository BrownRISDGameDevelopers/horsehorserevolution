extends Control

var note_info_scene = preload("res://scenes/game_scene/game_data/note_info.tscn")
var beat_sync = false
var beat_no = 0
var ending_beat = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func has_beat_info():
	return true

func init_beat(beat, synced):
	beat_no = beat
	beat_sync = synced
	$BeatNumber.text = str(beat)
	$SyncIndicator.button_pressed = synced

func set_ending():
	$BeatNumber.button_pressed = true

func set_toggle(notes_list):
	for note in notes_list:
		var button = get_node(note.get_uid())
		button.set_state(note.get_held())

func get_note_info():
	var notes_list = []
	if beat_sync:
		var player = Global.PlayerEnum.PLAYER_1
		for direction in Global.Direction:
			var note_info: NoteInfo = note_info_scene.instantiate()
			note_info.initialize(player, Global.Direction[direction], false)
			var button = get_node(note_info.get_uid())
			if button.get_pressed():
				notes_list.append({"player": Global.PlayerEnum.PLAYER_1, "direction": Global.Direction[direction], "held": button.get_held()})
				notes_list.append({"player": Global.PlayerEnum.PLAYER_2, "direction": Global.Direction[direction], "held": button.get_held()})
	else:
		for player in Global.PlayerEnum:
			for direction in Global.Direction:
				var note_info: NoteInfo = note_info_scene.instantiate()
				note_info.initialize(Global.PlayerEnum[player], Global.Direction[direction], false)
				var button = get_node(note_info.get_uid())
				if button.get_pressed():
					notes_list.append({"player": Global.PlayerEnum[player], "direction": Global.Direction[direction], "held": button.get_held()})
	return {"sync": beat_sync, "arrows": notes_list}

func get_sync():
	return beat_sync

func ends_song():
	return ending_beat

func _on_sync_indicator_toggled(toggled_on):
	$Player2Left.disabled = toggled_on
	$Player2Down.disabled = toggled_on
	$Player2Up.disabled = toggled_on
	$Player2Right.disabled = toggled_on
	beat_sync = toggled_on


func _on_beat_number_toggled(toggled_on: bool):
	$EndingBeatText.visible = toggled_on
	ending_beat = toggled_on
