extends Control

var note_info_scene = preload("res://scenes/game_scene/game_data/note_info.tscn")

var beat_sync = false
var beat_no = 0

signal note_info_updated(beat_no, notes_list)

func _get_uid(player, direction):
	return "Player" + str(int(player) + 1) + ["Left", "Down", "Up", "Right"][direction]

func _ready():
	for player in Global.PlayerEnum:
		for direction in Global.Direction:
			var uid = _get_uid(Global.PlayerEnum[player], Global.Direction[direction])
			var button = get_node(uid)
			button.state_updated.connect(_update_note_info)


func init_beat(beat, synced):
	beat_no = beat
	beat_sync = synced
	$SyncIndicator.text = str(beat) + "\n ⇄"
	$SyncIndicator.button_pressed = synced

func set_toggle(notes_list):
	for player in Global.PlayerEnum:
		for direction in Global.Direction:
			var uid = _get_uid(Global.PlayerEnum[player], Global.Direction[direction])
			var button = get_node(uid)
			button.set_state()
	for note in notes_list:
		var uid = _get_uid(note["player"], note["direction"])
		var button = get_node(uid)
		button.set_state(true, note["held"])

func _on_sync_indicator_toggled(toggled_on):
	$Player1Left.set_sync(toggled_on)
	$Player1Down.set_sync(toggled_on)
	$Player1Up.set_sync(toggled_on)
	$Player1Right.set_sync(toggled_on)
	$Player2Left.set_sync(toggled_on)
	$Player2Left.sync_state($Player1Left.current_state)
	$Player2Down.set_sync(toggled_on)
	$Player2Down.sync_state($Player1Down.current_state)
	$Player2Up.set_sync(toggled_on)
	$Player2Up.sync_state($Player1Up.current_state)
	$Player2Right.set_sync(toggled_on)
	$Player2Right.sync_state($Player1Right.current_state)
	beat_sync = toggled_on
	_update_note_info()


func _update_note_info():
	note_info_updated.emit(beat_no, _get_note_info())

func _get_note_info():
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
