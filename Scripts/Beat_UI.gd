extends Control

var note_info_scene = preload("res://Scenes/NoteInfo.tscn")
var sync = false
var beat_no = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func init_beat(beat):
    beat_no = beat
    $BeatNumber.text = "  " + str(beat) + "  "

func set_toggle(notes_list):
    for note in notes_list:
        var button = get_node(note.get_uid())
        button.button_pressed = true

func get_note_info():
    var notes_list = []
    if sync:
        for direction in [0, 1, 2, 3]:
            var note_info: NoteInfo = note_info_scene.instantiate()
            note_info.initialize(0, direction)
            var button = get_node(note_info.get_uid())
            if button.button_pressed:
                notes_list.append({"player": 0, "direction": direction})
                notes_list.append({"player": 1, "direction": direction})
        return notes_list
    for player in [0, 1]:
        for direction in [0, 1, 2, 3]:
            var note_info: NoteInfo = note_info_scene.instantiate()
            note_info.initialize(player, direction)
            var button = get_node(note_info.get_uid())
            if button.button_pressed:
                notes_list.append({"player": player, "direction": direction})
    return notes_list

func _on_sync_indicator_toggled(toggled_on):
    $Player2Left.disabled = toggled_on
    $Player2Down.disabled = toggled_on
    $Player2Up.disabled = toggled_on
    $Player2Right.disabled = toggled_on
    sync = toggled_on
