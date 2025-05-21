extends VBoxContainer

@export var beat_uis: Array[HBoxContainer]

var notes = {}
var current_beat = 1

signal scroll_up
signal scroll_down

func _ready():
	for beat_ui in beat_uis:
		beat_ui.note_info_updated.connect(update_note_json)
	scroll_to(current_beat)
	gui_input.connect(handle_scroll)

func handle_scroll(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_up.emit()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_down.emit()

func scroll_to(beat_no):
	current_beat = beat_no
	for i in range(5):
		var synced = false
		var notes_list = []
		var beat_adj = str(beat_no + i)
		if beat_adj in notes:
			synced = notes[beat_adj]["sync"]
			notes_list = notes[beat_adj]["arrows"]
		beat_uis[i].init_beat(beat_no + i, synced)
		beat_uis[i].set_toggle(notes_list)

func update_note_json(beat_no, notes_list):
	notes[str(beat_no)] = notes_list
