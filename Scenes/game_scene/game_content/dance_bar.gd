extends Node2D

@export var is_player: bool = false
@onready var bar: TextureProgressBar = $ProgressBar

const RED = "red"
const GREEN = "green"
var light_colors = {RED: "ED272F", GREEN: "3BB45A"}

func _ready():
	if is_player:
		bar.modulate = light_colors[GREEN]
	else:
		bar.modulate = light_colors[RED]
		bar.fill_mode = 1
	Global.dance_bar_change.connect(change_val)
	
func change_val(x):
	if is_player:
		bar.value = max(bar.value + x, 20)
	else:
		bar.value = max(bar.value - x, 20)
