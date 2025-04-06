extends Button

@export var arrow_char: String = "←"
var off_text: String
var off_color: Color = "ffffff"
var single_text: String
var single_color: Color = "ff6f69"
var hold_text: String
var hold_color: Color = "ffcc5c"
var display_text

enum State {OFF, SINGLE, HOLD}

var current_state: State = State.OFF

func _ready():
	off_text = " " + arrow_char + " "
	single_text = " " + arrow_char + "1"
	hold_text = " " + arrow_char + "H"
	display_text = off_text
	gui_input.connect(_on_press)

func _process(delta):
	if current_state == State.OFF:
		display_text = off_text
		modulate = off_color
	elif current_state == State.SINGLE:
		display_text = single_text
		modulate = single_color
	elif current_state == State.HOLD:
		display_text = hold_text
		modulate = hold_color
	text = display_text

func _on_press(event):
	if event is InputEventMouseButton and event.pressed:
		var adj = 0
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				adj = 1
			MOUSE_BUTTON_RIGHT:
				adj = -1
		var res = (int(current_state) + 3 + adj) % 3
		current_state = res as State

func set_state(held: bool = false):
	if not held:
		current_state = State.SINGLE
	else:
		current_state = State.HOLD

func get_pressed():
	if current_state == State.SINGLE:
		return true
	if current_state == State.HOLD:
		return true

func get_held():
	return current_state == State.HOLD
