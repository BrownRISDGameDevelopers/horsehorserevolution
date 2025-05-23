extends TextureButton

@export var direction: Global.Direction
@export var sync_partner: TextureButton

@onready var button_texture: TextureRect = $ButtonTexture
@onready var hold_label: Label = $HoldDisplay
@onready var sync_label: Label = $SyncDisplay

enum State {OFF, SINGLE, HOLD}

signal state_updated

var current_state: State = State.OFF
var synced := false

var text_colors = {Global.Direction.LEFT: "6dd2f9",
					Global.Direction.DOWN: "ed6eb3",
					Global.Direction.UP: "f6db62",
					Global.Direction.RIGHT: "6fee48"}

var toggled_modulate = {State.OFF: "666666",
						State.SINGLE: "FFFFFF",
						State.HOLD: "FFFFFF", }

var button_sprites = {Global.Direction.LEFT: "res://assets/image/game/arrow_button/left/left_neutral_cindy.png",
					Global.Direction.DOWN: "res://assets/image/game/arrow_button/down/down_neutral_cindy.png",
					Global.Direction.UP: "res://assets/image/game/arrow_button/up/up_neutral_cindy.png",
					Global.Direction.RIGHT: "res://assets/image/game/arrow_button/right/right_neutral_cindy.png"}

func _ready():
	button_texture.texture = load(button_sprites[direction])
	hold_label.modulate = text_colors[direction]
	sync_label.modulate = text_colors[direction]
	gui_input.connect(_on_press)
	
func _on_press(event):
	if event is InputEventMouseButton and event.pressed:
		var adj = 0
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				adj = 1
			MOUSE_BUTTON_RIGHT:
				adj = -1
		var res = (int(current_state) + 3 + adj) % 3
		_update_state(res as State)
		state_updated.emit()

func set_state(press: bool = false, held: bool = false):
	if not press:
		_update_state(State.OFF)
	elif press and not held:
		_update_state(State.SINGLE)
	else:
		_update_state(State.HOLD)

func _update_state(state: State):
	current_state = state
	button_texture.modulate = toggled_modulate[current_state]
	hold_label.visible = (current_state == State.HOLD)
	if synced:
		sync_partner.sync_state(current_state)

func set_sync(_synced: bool):
	synced = _synced
	sync_label.visible = synced

func sync_state(state: State):
	current_state = state
	button_texture.modulate = toggled_modulate[current_state]
	hold_label.visible = (current_state == State.HOLD)

func get_pressed():
	if current_state == State.OFF:
		return false
	if current_state == State.SINGLE:
		return true
	if current_state == State.HOLD:
		return true

func get_held():
	return current_state == State.HOLD
