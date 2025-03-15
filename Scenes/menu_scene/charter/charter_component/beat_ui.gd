extends Control

var note_info_scene = preload("res://scenes/game_scene/game_data/note_info.tscn")
var beat_sync = false
var beat_no = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init_beat(beat, synced):
	beat_no = beat
	beat_sync = synced
	$BeatNumber.text = "  " + str(beat) + "  "
	$SyncIndicator.button_pressed = synced

func set_toggle(notes_list):
	for note in notes_list:
		var button = get_node(note.get_uid())
		button.set_state(note.get_held())

func get_note_info():
	var notes_list = []
	if beat_sync:
		var player = 0
		for direction in [0, 1, 2, 3]:
			var note_info: NoteInfo = note_info_scene.instantiate()
			note_info.initialize(player, direction, false)
			var button = get_node(note_info.get_uid())
			if button.get_pressed():
				notes_list.append({"player": 0, "direction": direction, "held": button.get_held()})
				notes_list.append({"player": 1, "direction": direction, "held": button.get_held()})
	else:
		for player in [0, 1]:
			for direction in [0, 1, 2, 3]:
				var note_info: NoteInfo = note_info_scene.instantiate()
				note_info.initialize(player, direction, false)
				var button = get_node(note_info.get_uid())
				if button.get_pressed():
					notes_list.append({"player": player, "direction": direction, "held": button.get_held()})
	return {"sync": beat_sync, "arrows": notes_list}

func get_sync():
	return beat_sync

func _on_sync_indicator_toggled(toggled_on):
	$Player2Left.disabled = toggled_on
	$Player2Down.disabled = toggled_on
	$Player2Up.disabled = toggled_on
	$Player2Right.disabled = toggled_on
	beat_sync = toggled_on
