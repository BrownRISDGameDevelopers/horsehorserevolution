extends Button

@export var arrow_char: String = "←"
var off_text: String
var single_text: String
var hold_text: String
var display_text

enum STATE {OFF, SINGLE, HOLD}

var current_state: STATE = STATE.OFF

func _ready():
	off_text = " " + arrow_char + " "
	single_text = " " + arrow_char + "1"
	hold_text = " " + arrow_char + "H"
	display_text = off_text
	gui_input.connect(_on_press)

func _process(delta):
	if current_state == STATE.OFF:
		display_text = off_text
	elif current_state == STATE.SINGLE:
		display_text = single_text
	elif current_state == STATE.HOLD:
		display_text = hold_text
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
		current_state = res as STATE

func set_state(held: bool = false):
	if not held:
		current_state = STATE.SINGLE
	else:
		current_state = STATE.HOLD

func get_pressed():
	if current_state == STATE.SINGLE:
		return true
	if current_state == STATE.HOLD:
		return true

func get_held():
	return current_state == STATE.HOLD
